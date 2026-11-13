/// S31: add a lesson material from pasted text, a text file or a page photo.
///
/// PDF extraction is not implemented by the API, so PDF stays visibly
/// disabled instead of pretending to work.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/app_context.dart';
import '../../../core/config/constants.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/grade_labels.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../exams/domain/exam_repository.dart';
import '../domain/material_models.dart';
import 'material_source_view.dart';

class AddMaterialScreen extends StatefulWidget {
  const AddMaterialScreen({super.key});

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _text = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  late String? _grade = materialGradeValue(context.auth.profile?.classLevel);
  late final Future<CatalogueValues> _catalogue = context.services.examRepository.catalogue();

  MaterialSource _source = MaterialSource.paste;
  Uint8List? _bytes;
  String? _fileName;
  String? _contentType;
  bool _busy = false;
  String? _gradeError;
  String? _subjectError;
  String? _sourceError;

  @override
  void dispose() {
    _subject.dispose();
    _text.dispose();
    super.dispose();
  }

  void _setSource(MaterialSource source) => setState(() {
    _source = source;
    _sourceError = null;
  });

  void _accept(Uint8List bytes, String name, String? contentType) {
    if (bytes.isEmpty) {
      setState(() => _sourceError = context.l10n.errorMaterialFileMissing);
      return;
    }
    if (bytes.length > Limits.maxReceiptBytes) {
      setState(() => _sourceError = context.l10n.errorMaterialTooLarge);
      return;
    }
    setState(() {
      _bytes = bytes;
      _fileName = name;
      _contentType = contentType;
      _sourceError = null;
    });
  }

  Future<void> _pickTextFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['txt', 'md'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final PlatformFile file = result.files.single;
      final Uint8List? bytes = file.bytes;
      if (bytes == null) {
        if (mounted) setState(() => _sourceError = context.l10n.errorMaterialFileMissing);
        return;
      }
      if (!mounted) return;
      final String text = utf8.decode(bytes, allowMalformed: true).trim();
      if (text.length < materialMinChars) {
        setState(() => _sourceError = context.l10n.materialTooShort);
        return;
      }
      _accept(bytes, file.name, file.name.toLowerCase().endsWith('.md') ? 'text/markdown' : 'text/plain');
    } on Exception {
      if (mounted) setState(() => _sourceError = context.l10n.errorMaterialFileMissing);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 2400, imageQuality: 90);
      if (file == null) return;
      final Uint8List bytes = await file.readAsBytes();
      if (!mounted) return;
      _accept(bytes, file.name, file.mimeType ?? _imageType(file.name));
    } on Exception {
      if (mounted) setState(() => _sourceError = context.l10n.errorMaterialFileMissing);
    }
  }

  static String _imageType(String name) => name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';

  Future<void> _submit() async {
    final String subject = _subject.text.trim();
    final String? grade = _grade;
    String? gradeError;
    String? subjectError;
    String? sourceError;
    if (grade == null) gradeError = context.l10n.materialGradeRequired;
    if (subject.isEmpty) subjectError = context.l10n.materialSubjectRequired;
    if (_source == MaterialSource.paste) {
      if (_text.text.trim().length < materialMinChars) sourceError = context.l10n.materialTooShort;
    } else if (_bytes == null) {
      sourceError = context.l10n.materialNoFile;
    }
    setState(() {
      _gradeError = gradeError;
      _subjectError = subjectError;
      _sourceError = sourceError;
    });
    if (gradeError != null || subjectError != null || sourceError != null) return;

    setState(() => _busy = true);
    final String language = context.localeController.languageCode;
    try {
      if (_source == MaterialSource.paste) {
        await context.services.materialsRepository.addText(
          classLevel: grade!,
          subject: subject,
          language: language,
          text: _text.text.trim(),
        );
      } else {
        await context.services.materialsRepository.addFile(
          classLevel: grade!,
          subject: subject,
          language: language,
          bytes: _bytes!,
          fileName: _fileName ?? 'material',
          contentType: _contentType ?? 'text/plain',
        );
      }
      if (!mounted) return;
      context.snack(context.l10n.materialSaved);
      context.pop(true);
    } on AppFailure catch (failure) {
      if (mounted) {
        setState(() => _sourceError = failure.code == 'NETWORK_ERROR' ? context.l10n.materialDraftKept : null);
        context.snack(failureMessage(context.l10n, failure));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double gutter = AppSpacing.gutterOf(context);
    return AppPage(
      title: context.l10n.materialAdd,
      child: ListView(
        padding: EdgeInsets.fromLTRB(gutter, AppSpacing.sm, gutter, AppSpacing.xl),
        children: <Widget>[
          SectionCard(
            title: context.l10n.classLevel,
            child: _GradeChoices(
              value: _grade,
              onChanged: (String value) => setState(() {
                _grade = value;
                _gradeError = null;
              }),
            ),
          ),
          if (_gradeError != null) _ErrorLine(text: _gradeError!),
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            title: context.l10n.subject,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppTextField(
                  label: context.l10n.subject,
                  controller: _subject,
                  hint: context.l10n.materialSubjectHint,
                  errorText: _subjectError,
                  onChanged: (_) {
                    if (_subjectError != null) setState(() => _subjectError = null);
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                FutureBuilder<CatalogueValues>(
                  future: _catalogue,
                  builder: (BuildContext context, AsyncSnapshot<CatalogueValues> snapshot) {
                    final List<String> subjects = snapshot.data?.subjects ?? const <String>[];
                    if (subjects.isEmpty) return const SizedBox.shrink();
                    return Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: <Widget>[
                        for (final String name in subjects)
                          ActionChip(
                            label: Text(name),
                            onPressed: () => setState(() {
                              _subject.text = name;
                              _subjectError = null;
                            }),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            title: context.l10n.materialSource,
            child: MaterialSourceView(
              source: _source,
              text: _text,
              error: _sourceError,
              fileName: _fileName,
              bytes: _bytes,
              onSource: _setSource,
              onPickText: _pickTextFile,
              onPickImage: _pickImage,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.materialPrivacyNote,
            style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant, height: 1.6),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: context.l10n.save, isLoading: _busy, onPressed: _busy ? null : _submit),
        ],
      ),
    );
  }
}

class _GradeChoices extends StatelessWidget {
  const _GradeChoices({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: <Widget>[
        for (final String grade in const <String>['1', '2', '3'])
          ChoiceChip(
            label: Text(gradeLabel(context.l10n, grade)),
            selected: value == grade,
            onSelected: (_) => onChanged(grade),
          ),
      ],
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xxs),
    child: Text(text, style: context.text.bodySmall?.copyWith(color: context.scheme.error)),
  );
}
