/// One payment request: status and next action first, then the exact amount,
/// labeled transfer details, the receipt action and the review timeline.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/config/constants.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/failure.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/states.dart';
import '../domain/payment_models.dart';
import 'payment_detail_body.dart';
import 'receipt_viewer.dart';

class PaymentDetailScreen extends StatefulWidget {
  const PaymentDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  PaymentRequest? _request;
  AppFailure? _failure;
  bool _loading = true;
  bool _cancelling = false;
  bool _refreshing = false;
  Timer? _poll;
  DateTime? _pollDeadline;
  PaymentStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _load({bool quiet = false, bool notify = false}) async {
    if (quiet) {
      if (_refreshing) return;
      setState(() => _refreshing = true);
    } else {
      setState(() {
        _loading = true;
        _failure = null;
      });
    }
    try {
      final PaymentRequest request = await context.services.paymentRepository.getRequest(widget.requestId);
      if (!mounted) return;
      final PaymentStatus? previous = _lastStatus;
      _lastStatus = request.status;
      setState(() {
        _request = request;
        _loading = false;
        _failure = null;
      });
      if (previous != null && previous != PaymentStatus.approved && request.status == PaymentStatus.approved) {
        unawaited(context.walletController.load());
        context.snack(context.l10n.paymentApprovedTitle);
      }
      _syncPolling(request);
    } on AppFailure catch (failure) {
      if (!mounted) return;
      if (quiet) {
        if (notify) context.snack(failureMessage(context.l10n, failure));
      } else {
        setState(() {
          _loading = false;
          _failure = failure;
        });
      }
    } finally {
      if (mounted && _refreshing) setState(() => _refreshing = false);
    }
  }

  /// Review can move while the student watches; poll at a calm rate for a
  /// couple of minutes instead of leaving the screen stale.
  void _syncPolling(PaymentRequest request) {
    if (!request.status.isWaiting) {
      _poll?.cancel();
      _poll = null;
      return;
    }
    _pollDeadline ??= DateTime.now().add(Limits.paymentPollMax);
    _poll ??= Timer.periodic(Limits.paymentPollStart, (Timer timer) {
      if (!mounted || DateTime.now().isAfter(_pollDeadline!)) {
        timer.cancel();
        _poll = null;
        return;
      }
      unawaited(_load(quiet: true));
    });
  }

  Future<void> _cancel() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.cancelConfirmTitle),
        content: Text(context.l10n.cancelConfirmBody),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.cancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(context.l10n.cancelRequest)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _cancelling = true);
    try {
      final PaymentRequest updated = await context.services.paymentRepository.cancelRequest(widget.requestId);
      if (!mounted) return;
      setState(() => _request = updated);
      context.snack(context.l10n.requestCancelled);
    } on AppFailure catch (failure) {
      if (mounted) context.snack(failureMessage(context.l10n, failure));
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Future<void> _submit() async {
    final bool? submitted = await context.push<bool>(Routes.paymentSubmitOf(widget.requestId));
    if (submitted == true && mounted) {
      context.snack(context.l10n.paymentSubmitted);
      unawaited(_load(quiet: true));
    }
  }

  Future<void> _openBankak() async {
    final Uri intent = Uri.parse('intent://#Intent;package=${AppInfo.bankakPackage};end');
    bool opened = false;
    try {
      opened = await launchUrl(intent, mode: LaunchMode.externalApplication);
    } on Exception {
      opened = false;
    }
    if (!opened && mounted) context.snack(context.l10n.bankakNotInstalled);
  }

  void _viewReceipt(PaymentRequest request) {
    showDialog<void>(context: context, builder: (BuildContext dialogContext) => ReceiptViewer(request: request));
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: context.l10n.paymentsTitle,
      actions: <Widget>[
        IconButton(
          onPressed: _refreshing ? null : () => _load(quiet: true, notify: true),
          icon: _refreshing
              ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.refresh_rounded),
          tooltip: context.l10n.refreshStatus,
        ),
      ],
      child: switch ((_loading, _failure, _request)) {
        (true, _, _) => const Center(child: CircularProgressIndicator()),
        (_, final AppFailure failure, _) => ErrorView(failure: failure, onRetry: _load),
        (_, _, final PaymentRequest request) => PaymentDetailBody(
          request: request,
          cancelling: _cancelling,
          onRefresh: () => _load(quiet: true, notify: true),
          onSubmit: _submit,
          onCancel: _cancel,
          onOpenBankak: _openBankak,
          onNewRequest: () => context.push(Routes.packages),
          onViewReceipt: () => _viewReceipt(request),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

