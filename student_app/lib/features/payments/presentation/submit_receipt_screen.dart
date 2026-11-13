/// Prepares the picked receipt locally, uploads it once, and lets the server
/// read the transaction reference and sender name out of the image. The student
/// only checks what was filled in and sends; the server still validates all.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/failure.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/states.dart';
import '../data/receipt_media.dart';
import '../domain/payment_models.dart';
import '../domain/payment_repository.dart';
import 'receipt_extraction.dart';
import 'receipt_picker.dart';
import 'receipt_picking.dart';
import 'receipt_source_sheet.dart';
import 'receipt_submit_form.dart';
import 'receipt_viewer.dart';

class SubmitReceiptScreen extends StatefulWidget {
  const SubmitReceiptScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<SubmitReceiptScreen> createState() => _SubmitReceiptScreenState();
}

class _SubmitReceiptScreenState extends State<SubmitReceiptScreen> {
  late Future<PaymentRequest> _request = context.services.paymentRepository.getRequest(widget.requestId);
  final TextEditingController _reference = TextEditingController();
  final TextEditingController _sender = TextEditingController();

  ReceiptDraft? _draft;
  String? _uploadedReceiptId;
  bool _compressed = false;
  String? _referenceError;
  String? _receiptError;
  bool _preparing = false;
  bool _busy = false;
  bool _uploading = false;
  ReceiptRead _read = ReceiptRead.none;
  int _readToken = 0;

  @override
  void dispose() {
    _reference.dispose();
    _sender.dispose();
    super.dispose();
  }

  Future<void> _accept(ReceiptPick pick) async {
    setState(() {
      _preparing = true;
      _receiptError = null;
    });
    try {
      final ReceiptDraft draft = await prepareReceipt(
        bytes: pick.bytes,
        fileName: pick.name,
        contentType: pick.contentType,
      );
      if (!mounted) return;
      setState(() {
        _draft = draft;
        _compressed = draft.bytes.lengthInBytes < pick.bytes.lengthInBytes;
        _preparing = false;
      });
      await _uploadAndRead(draft);
    } on ReceiptMediaException catch (error) {
      if (!mounted) return;
      setState(() {
        _receiptError = receiptMediaMessage(context, error);
        _preparing = false;
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        _receiptError = context.l10n.receiptPrepareFailed;
        _preparing = false;
      });
    }
  }

  Future<void> _chooseSource() async {
    final ReceiptSource? source = await showReceiptSourceSheet(context);
    if (source != null && mounted) await _pick(source);
  }

  Future<void> _pick(ReceiptSource source) async {
    try {
      final ReceiptPick? pick = await pickReceipt(context, source);
      if (pick == null || !mounted) return;
      await _accept(pick);
    } on ReceiptPickException catch (error) {
      if (mounted) setState(() => _receiptError = error.message);
    }
  }

  void _startReading() {
    _readToken += 1;
    setState(() {
      _uploadedReceiptId = null;
      _read = ReceiptRead.none;
    });
  }

  /// Uploads the picked receipt and lets the server read the reference and the
  /// sender name out of it, so the student only has to check and send.
  Future<void> _uploadAndRead(ReceiptDraft draft) async {
    _startReading();
    final int token = _readToken;
    final PaymentRepository repository = context.services.paymentRepository;
    setState(() {
      _uploading = true;
      _read = ReceiptRead.reading;
    });
    try {
      final ReceiptFile uploaded = await repository.uploadReceipt(draft);
      if (!mounted || token != _readToken) return;
      setState(() {
        _uploadedReceiptId = uploaded.id;
        _uploading = false;
      });
      if (!uploaded.isReading) {
        // A PDF, or a server with AI switched off: no note, the student just types.
        setState(() => _read = uploaded.extraction == ReceiptExtraction.off
            ? ReceiptRead.none
            : ReceiptRead.manual);
        return;
      }
      final ReceiptFile? settled = await readUploadedReceipt(
        repository,
        uploaded.id,
        isCurrent: () => mounted && token == _readToken,
      );
      if (!mounted || token != _readToken) return;
      if (settled == null) {
        setState(() => _read = ReceiptRead.manual);
        return;
      }
      _apply(settled);
    } on AppFailure {
      // The draft is still here, so submit will retry the upload itself.
      if (!mounted || token != _readToken) return;
      setState(() {
        _uploading = false;
        _read = ReceiptRead.manual;
      });
    }
  }

  void _apply(ReceiptFile receipt) => setState(
    () => _read = applyReceiptFields(receipt: receipt, reference: _reference, sender: _sender),
  );

  Future<void> _submit(PaymentRequest request) async {
    final String reference = _reference.text.trim();
    final String? referenceError = reference.length < 4 ? context.l10n.errorInvalidReference : null;
    final bool receiptMissing = _draft == null && request.receipt == null && _uploadedReceiptId == null;
    setState(() {
      _referenceError = referenceError;
      _receiptError = receiptMissing ? context.l10n.errorReceiptRequired : null;
    });
    if (referenceError != null || receiptMissing || _preparing) return;

    setState(() => _busy = true);
    final paymentRepository = context.services.paymentRepository;
    try {
      String? receiptId = _uploadedReceiptId;
      if (receiptId == null && _draft != null) {
        setState(() => _uploading = true);
        final ReceiptFile uploaded = await paymentRepository.uploadReceipt(_draft!);
        receiptId = uploaded.id;
        if (mounted) setState(() => _uploadedReceiptId = receiptId);
      }
      final String sender = _sender.text.trim();
      await paymentRepository.submitReceipt(
        request.id,
        PaymentSubmission(reference: reference, senderName: sender.isEmpty ? null : sender, receiptId: receiptId),
      );
      if (mounted) context.pop(true);
    } on AppFailure catch (failure) {
      if (!mounted) return;
      final String? field = failure.fieldError('reference');
      setState(() {
        if (field != null) _referenceError = fieldMessage(context.l10n, failure, 'reference');
      });
      context.snack(failureMessage(context.l10n, failure));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _uploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: context.l10n.submitReceipt,
      child: FutureBuilder<PaymentRequest>(
        future: _request,
        builder: (BuildContext context, AsyncSnapshot<PaymentRequest> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final Object error = snapshot.error!;
            return ErrorView(
              failure: error is AppFailure ? error : const AppFailure.network(),
              onRetry: () => setState(() {
                _request = context.services.paymentRepository.getRequest(widget.requestId);
              }),
            );
          }
          final PaymentRequest request = snapshot.data!;
          return ReceiptSubmitForm(
            request: request,
            reference: _reference,
            sender: _sender,
            draft: _draft,
            preparing: _preparing,
            uploaded: _uploadedReceiptId != null,
            compressed: _compressed,
            busy: _busy,
            uploading: _uploading,
            referenceError: _referenceError,
            receiptError: _receiptError,
            read: _read,
            onPick: _pick,
            onReplace: _chooseSource,
            onRemove: () {
              _startReading();
              setState(() {
                _draft = null;
                _compressed = false;
              });
            },
            onViewAttached: () => showDialog<void>(
              context: context,
              builder: (BuildContext dialogContext) => ReceiptViewer(request: request),
            ),
            onSubmit: () => _submit(request),
          );
        },
      ),
    );
  }
}
