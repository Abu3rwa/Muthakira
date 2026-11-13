import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:student_app/app/app_services.dart';
import 'package:student_app/core/l10n/formatters.dart';
import 'package:student_app/core/l10n/generated/app_localizations.dart';
import 'package:student_app/core/l10n/locale_controller.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/features/payments/domain/payment_models.dart';
import 'package:student_app/features/payments/domain/payment_repository.dart';
import 'package:student_app/features/payments/presentation/receipt_extraction.dart';
import 'package:student_app/features/payments/presentation/receipt_submit_form.dart';
import 'package:student_app/shared/widgets/primary_button.dart';

class _MockServices extends Mock implements AppServices {}

class _MockLocale extends Mock implements LocaleController {}

class _MockPayments extends Mock implements PaymentRepository {}

ReceiptFile _receipt({
  ReceiptExtraction extraction = ReceiptExtraction.done,
  String? reference = 'BK123456',
  String? sender = 'سلمى علي',
}) => ReceiptFile(
  id: 'rcpt-1',
  contentType: 'image/png',
  sizeBytes: 1024,
  extraction: extraction,
  extractedReference: reference,
  extractedSenderName: sender,
);

PaymentRequest _request() => PaymentRequest.fromJson(<String, Object?>{
  'id': 'payment-1',
  'status': 'pending_payment',
  'payment_code': 'AB12CD',
  'package': <String, Object?>{
    'id': 'starter',
    'name': <String, Object?>{'ar': 'باقة البداية', 'en': 'Starter package'},
    'credits': 100,
    'price_sdg': 1000,
  },
  'receiving_account': '1234567890',
  'base_amount_sdg': 1000,
  'amount_increment': 1,
  'expected_amount_sdg': 1001,
  'duplicate_across_accounts': false,
});

void main() {
  late _MockServices services;
  late _MockLocale locale;

  setUp(() {
    services = _MockServices();
    locale = _MockLocale();
    when(() => services.locale).thenReturn(locale);
    when(() => locale.languageCode).thenReturn('ar');
  });

  group('readUploadedReceipt', () {
    test('polls until the server has read the receipt', () async {
      final _MockPayments payments = _MockPayments();
      final List<ReceiptFile> answers = <ReceiptFile>[
        _receipt(extraction: ReceiptExtraction.pending, reference: null, sender: null),
        _receipt(extraction: ReceiptExtraction.pending, reference: null, sender: null),
        _receipt(),
      ];
      int call = 0;
      when(
        () => payments.receiptStatus('rcpt-1'),
      ).thenAnswer((_) async => answers[call++]);

      final ReceiptFile? settled = await readUploadedReceipt(
        payments,
        'rcpt-1',
        isCurrent: () => true,
        interval: const Duration(milliseconds: 1),
      );

      expect(call, 3);
      expect(settled?.extraction, ReceiptExtraction.done);
      expect(settled?.extractedReference, 'BK123456');
    });

    test('stops as soon as the student replaces the receipt', () async {
      final _MockPayments payments = _MockPayments();
      bool current = true;
      when(() => payments.receiptStatus(any())).thenAnswer((_) async => _receipt());

      final Future<ReceiptFile?> wait = readUploadedReceipt(
        payments,
        'rcpt-1',
        isCurrent: () => current,
        interval: const Duration(milliseconds: 1),
      );
      current = false;

      expect(await wait, isNull);
      verifyNever(() => payments.receiptStatus(any()));
    });

    test('gives up after its attempts run out', () async {
      final _MockPayments payments = _MockPayments();
      when(
        () => payments.receiptStatus(any()),
      ).thenAnswer((_) async => _receipt(extraction: ReceiptExtraction.pending, reference: null, sender: null));

      final ReceiptFile? settled = await readUploadedReceipt(
        payments,
        'rcpt-1',
        isCurrent: () => true,
        interval: const Duration(milliseconds: 1),
        maxPolls: 3,
      );

      expect(settled, isNull);
      verify(() => payments.receiptStatus('rcpt-1')).called(3);
    });
  });

  group('applyReceiptFields', () {
    test('fills empty fields and keeps what the student typed', () {
      final TextEditingController reference = TextEditingController(text: 'BK999999');
      final TextEditingController sender = TextEditingController();

      final ReceiptRead read = applyReceiptFields(
        receipt: _receipt(),
        reference: reference,
        sender: sender,
      );

      expect(read, ReceiptRead.filled);
      expect(reference.text, 'BK999999');
      expect(sender.text, 'سلمى علي');
      reference.dispose();
      sender.dispose();
    });

    test('an unreadable receipt leaves both fields empty and says so', () {
      final TextEditingController reference = TextEditingController();
      final TextEditingController sender = TextEditingController();

      final ReceiptRead read = applyReceiptFields(
        receipt: _receipt(extraction: ReceiptExtraction.failed, reference: null, sender: null),
        reference: reference,
        sender: sender,
      );

      expect(read, ReceiptRead.manual);
      expect(reference.text, isEmpty);
      expect(sender.text, isEmpty);
      reference.dispose();
      sender.dispose();
    });
  });

  test('a receipt without extraction fields is treated as manual', () {
    final ReceiptFile receipt = ReceiptFile.fromJson(<String, Object?>{
      'id': 'rcpt-1',
      'content_type': 'image/png',
      'size_bytes': 10,
    });
    expect(receipt.extraction, ReceiptExtraction.off);
    expect(receipt.isReading, isFalse);
    expect(receipt.extractedReference, isNull);
  });

  Future<void> openForm(WidgetTester tester, {required ReceiptRead read, String language = 'ar'}) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    when(() => locale.languageCode).thenReturn(language);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppServices>.value(value: services),
          Provider<Formatters>.value(value: Formatters(locale: language)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ReceiptSubmitForm(
              request: _request(),
              reference: TextEditingController(),
              sender: TextEditingController(),
              draft: ReceiptDraft(
                bytes: base64Decode(
                  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
                ),
                fileName: 'receipt.png',
                contentType: 'image/png',
              ),
              preparing: false,
              uploaded: true,
              compressed: false,
              busy: false,
              uploading: false,
              referenceError: null,
              receiptError: null,
              read: read,
              onPick: (_) {},
              onReplace: () {},
              onRemove: () {},
              onViewAttached: () {},
              onSubmit: () {},
            ),
          ),
        ),
      ),
    );
    // A pumpAndSettle here would hang forever while read == reading: the note
    // spins a CircularProgressIndicator.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
  }

  /// The form is a scrolling ListView, so anything below the fold is not built
  /// until it is reached. Dragging by hand avoids settling on the read spinner.
  Future<void> reveal(WidgetTester tester, Finder target) async {
    for (var i = 0; i < 10 && !target.tryEvaluate(); i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -240));
      await tester.pump();
    }
    expect(target, findsOneWidget);
  }

  for (final String language in <String>['ar', 'en']) {
    testWidgets('the read note explains what happened in $language', (tester) async {
      await openForm(tester, read: ReceiptRead.none, language: language);
      final AppLocalizations l10n = AppLocalizations.of(tester.element(find.byType(ReceiptSubmitForm)));

      await openForm(tester, read: ReceiptRead.filled, language: language);
      await reveal(tester, find.text(l10n.receiptExtracted));

      await openForm(tester, read: ReceiptRead.manual, language: language);
      await reveal(tester, find.text(l10n.receiptExtractManual));

      await openForm(tester, read: ReceiptRead.reading, language: language);
      await reveal(tester, find.text(l10n.receiptReading));

      expect(tester.takeException(), isNull);
    });

    testWidgets('sending waits for the read in $language', (tester) async {
      await openForm(tester, read: ReceiptRead.filled, language: language);
      await reveal(tester, find.byType(PrimaryButton));
      expect(tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed, isNotNull);

      await openForm(tester, read: ReceiptRead.reading, language: language);
      await reveal(tester, find.byType(PrimaryButton));
      expect(tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed, isNull);

      expect(tester.takeException(), isNull);
    });
  }
}
