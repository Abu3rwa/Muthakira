import { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { applyImport, dryRunImport, resetImport } from '../features/exams/examsSlice.js';
import { toast } from '../app/feedback.js';
import { readCsvFile } from '../lib/csv.js';
import { buildImportPrompt, copyText } from '../lib/importPrompt.js';
import { formatMarks } from '../lib/format.js';
import Icon from '../components/Icon.jsx';
import { Credits, Ltr } from '../components/Data.jsx';
import { InlineError } from '../components/States.jsx';

const FILES = [
  { name: 'exams', labelKey: 'import.examsFile', required: true },
  { name: 'stimuli', labelKey: 'import.stimuliFile', required: false },
  { name: 'questions', labelKey: 'import.questionsFile', required: true },
];

const SAMPLE_FILES = ['exams.csv', 'stimuli.csv', 'questions.csv'];

const READ_ERRORS = {
  FILE_TOO_LARGE: 'import.fileTooLarge',
  NOT_CSV: 'import.notCsv',
  READ_FAILED: 'import.readFailed',
  NO_FILE: 'import.needFiles',
};

function FilePicker({ name, label, required, file, text, error, disabled, onPick }) {
  const { t } = useTranslation();
  const input = useRef(null);
  const [over, setOver] = useState(false);

  const take = async (chosen) => {
    if (!chosen) return;
    await onPick(name, chosen);
  };

  return (
    <div
      className={`dropzone${over ? ' dropzone--over' : ''}`}
      onDragOver={(event) => {
        event.preventDefault();
        setOver(true);
      }}
      onDragLeave={() => setOver(false)}
      onDrop={(event) => {
        event.preventDefault();
        setOver(false);
        take(event.dataTransfer.files?.[0]);
      }}
    >
      <div className="row row--between">
        <strong>{label}</strong>
        {required ? <span className="badge badge--warning">{t('app.required')}</span> : null}
      </div>
      <span className="dropzone__name">{file ? file.name : t('import.noFile')}</span>
      {text ? (
        <span className="muted" style={{ fontSize: 'var(--text-xs)' }}>
          {t('import.rows', { count: Math.max(0, text.split(/\r?\n/).filter(Boolean).length - 1) })}
        </span>
      ) : null}
      <input
        ref={input}
        type="file"
        accept=".csv,text/csv"
        className="sr-only"
        id={`file-${name}`}
        aria-label={label}
        aria-hidden="true"
        tabIndex={-1}
        disabled={disabled}
        onChange={(event) => take(event.target.files?.[0])}
      />
      <div className="row">
        <button
          type="button"
          className="btn btn--outline btn--sm"
          disabled={disabled}
          onClick={() => input.current?.click()}
        >
          <Icon name="upload" size={14} />
          {t('import.chooseFile')}
        </button>
        {text ? (
          <span className="badge badge--success">
            <Icon name="check" size={11} />
            {t('app.yes')}
          </span>
        ) : null}
      </div>
      {error ? (
        <span className="field__error" role="alert">
          {error}
        </span>
      ) : null}
    </div>
  );
}

function ProblemTable({ title, rows, tone, columns }) {
  const { t } = useTranslation();
  if (!rows.length) return null;
  return (
    <div className="card">
      <div className="card__head">
        <Icon name={tone === 'danger' ? 'alert' : 'flag'} />
        <h2 className="grow">{title}</h2>
        <span className={`badge badge--${tone}`}>{rows.length}</span>
      </div>
      <div className="card__body card__body--flush">
        <div className="table-wrap" style={{ maxHeight: 340, border: 0, borderRadius: 0, boxShadow: 'none' }}>
          <table className="table table--responsive">
            <thead>
              <tr>
                {columns.map((column) => (
                  <th key={column.key}>{column.label}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {rows.map((row, index) => (
                <tr key={`${row.file}-${row.line}-${index}`}>
                  {columns.map((column) => (
                    <td key={column.key} data-label={column.label} className={column.className ?? ''}>
                      {column.render ? column.render(row) : (row[column.key] ?? t('app.none'))}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

export default function ExamImportPage() {
  const { t, i18n } = useTranslation();
  const dispatch = useAppDispatch();
  const state = useAppSelector((slice) => slice.exams.import);
  const [files, setFiles] = useState({ exams: null, stimuli: null, questions: null });
  const [texts, setTexts] = useState({ exams: '', stimuli: '', questions: '' });
  const [readErrors, setReadErrors] = useState({});
  const [signature, setSignature] = useState(null);

  useEffect(() => () => dispatch(resetImport()), [dispatch]);

  const pick = async (name, file) => {
    setReadErrors((current) => ({ ...current, [name]: null }));
    try {
      const text = await readCsvFile(file);
      setFiles((current) => ({ ...current, [name]: file }));
      setTexts((current) => ({ ...current, [name]: text }));
      dispatch(resetImport());
      setSignature(null);
    } catch (error) {
      setFiles((current) => ({ ...current, [name]: null }));
      setTexts((current) => ({ ...current, [name]: '' }));
      setReadErrors((current) => ({
        ...current,
        [name]: t(READ_ERRORS[error.message] ?? 'import.readFailed'),
      }));
    }
  };

  const ready = Boolean(texts.exams && texts.questions);
  const busy = state.phase === 'checking' || state.phase === 'applying';
  const currentSignature = `${texts.exams.length}:${texts.stimuli.length}:${texts.questions.length}`;
  const stale = state.phase === 'checked' && signature !== null && signature !== currentSignature;
  const canApply = state.phase === 'checked' && state.ok && !stale && ready;

  const payload = () => ({
    exams: texts.exams,
    questions: texts.questions,
    ...(texts.stimuli ? { stimuli: texts.stimuli } : {}),
  });

  const validate = async () => {
    setSignature(currentSignature);
    try {
      const result = await dispatch(dryRunImport(payload())).unwrap();
      dispatch(
        toast(
          result.ok ? t('import.dryRunOk') : t('import.hasErrors'),
          result.ok ? 'success' : 'danger',
          result.ok ? undefined : t('errors.EXAM_IMPORT_INVALID'),
        ),
      );
    } catch {
      dispatch(toast(t('app.errorTitle'), 'danger'));
    }
  };

  const copyPrompt = async () => {
    const copied = await copyText(buildImportPrompt(i18n.language));
    dispatch(toast(t(copied ? 'import.copied' : 'import.copyFailed'), copied ? 'success' : 'danger'));
  };

  const apply = async () => {
    try {
      const result = await dispatch(applyImport(payload())).unwrap();
      if (result.ok) {
        dispatch(toast(t('import.applied'), 'success'));
      } else {
        dispatch(toast(t('import.hasErrors'), 'danger'));
      }
    } catch {
      dispatch(toast(t('app.errorTitle'), 'danger'));
    }
  };

  const problemColumns = [
    { key: 'file', label: t('import.file'), render: (row) => <Ltr className="mono">{row.file}</Ltr> },
    { key: 'line', label: t('import.line'), className: 'num' },
    { key: 'field', label: t('import.field'), render: (row) => <Ltr className="mono">{row.field ?? row.path ?? '—'}</Ltr> },
    { key: 'message', label: t('import.message') },
  ];

  return (
    <div className="page">
      <div className="page-head">
        <div className="page-head__title">
          <h1>{t('import.title')}</h1>
          <p>{t('import.subtitle')}</p>
        </div>
        <div className="page-head__actions">
          <Link to="/exams" className="btn btn--ghost btn--sm">
            <Icon name="chevronRight" size={14} className="flip-rtl" />
            {t('exams.title')}
          </Link>
        </div>
      </div>

      <div className="notice">
        <Icon name="alert" />
        <span>{t('import.hint')}</span>
      </div>

      <div className="card">
        <div className="card__body">
          <div className="row row--between wrap">
            <div>
              <div className="row" style={{ gap: 8 }}>
                <Icon name="box" />
                <strong>{t('import.samplesTitle')}</strong>
              </div>
              <p className="muted" style={{ fontSize: 'var(--text-sm)', margin: '4px 0 0' }}>
                {t('import.samplesHint')}
              </p>
            </div>
            <div className="row wrap">
              <button type="button" className="btn btn--primary btn--sm" onClick={copyPrompt}>
                <Icon name="copy" size={14} />
                {t('import.copyPrompt')}
              </button>
              {SAMPLE_FILES.map((name) => (
                <a key={name} className="btn btn--ghost btn--sm" href={`/samples/${name}`} download>
                  <Icon name="box" size={14} />
                  <Ltr className="mono">{name}</Ltr>
                </a>
              ))}
            </div>
          </div>
          <p className="muted" style={{ fontSize: 'var(--text-sm)', margin: '12px 0 0' }}>
            {t('import.copyPromptHint')}
          </p>
        </div>
      </div>

      <div className="card">
        <div className="card__body stack">
          <div className="split split--even" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))' }}>
            {FILES.map((entry) => (
              <FilePicker
                key={entry.name}
                name={entry.name}
                label={t(entry.labelKey)}
                required={entry.required}
                file={files[entry.name]}
                text={texts[entry.name]}
                error={readErrors[entry.name]}
                disabled={busy}
                onPick={pick}
              />
            ))}
          </div>

          {!ready ? <p className="field__hint">{t('import.needFiles')}</p> : null}
          {stale ? (
            <div className="notice notice--warning" role="alert">
              <Icon name="alert" />
              <span>{t('import.stale')}</span>
            </div>
          ) : null}

          <div className="row wrap">
            <button type="button" className="btn btn--secondary" disabled={!ready || busy} onClick={validate}>
              {state.phase === 'checking' ? <span className="spinner" aria-hidden="true" /> : <Icon name="check" />}
              {state.phase === 'checking' ? t('import.validating') : t('import.dryRun')}
            </button>
            <button
              type="button"
              className="btn btn--primary"
              disabled={!canApply || busy}
              onClick={apply}
              title={canApply ? undefined : t('import.hasErrors')}
            >
              {state.phase === 'applying' ? <span className="spinner" aria-hidden="true" /> : <Icon name="upload" />}
              {state.phase === 'applying' ? t('import.applying') : t('import.applyImport')}
            </button>
            <span className="grow" />
            {state.phase === 'checked' && state.ok ? (
              <span className="badge badge--success">{t('import.noErrors')}</span>
            ) : null}
            {state.phase === 'checked' && !state.ok ? (
              <span className="badge badge--danger">{t('import.hasErrors')}</span>
            ) : null}
          </div>

          <InlineError error={state.error} />
        </div>
      </div>

      {state.phase !== 'idle' && state.phase !== 'checking' && state.phase !== 'failed' ? (
        <>
          {state.exams.length ? (
            <div className="card">
              <div className="card__head">
                <Icon name="paper" />
                <h2 className="grow">{t('import.papers')}</h2>
                <span className="muted" style={{ fontSize: 'var(--text-xs)' }}>
                  {state.phase === 'applied' ? t('import.applied') : t('import.dryRunOk')}
                </span>
              </div>
              <div className="card__body card__body--flush">
                <div className="table-wrap" style={{ maxHeight: 300, border: 0, borderRadius: 0, boxShadow: 'none' }}>
                  <table className="table table--responsive">
                    <thead>
                      <tr>
                        <th>{t('exams.examKey')}</th>
                        <th>{t('import.action')}</th>
                        <th>{t('app.status')}</th>
                        <th className="num">{t('import.questionCount')}</th>
                        <th className="num">{t('import.leafCount')}</th>
                        <th className="num">{t('import.leafMarks')}</th>
                      </tr>
                    </thead>
                    <tbody>
                      {state.exams.map((exam) => (
                        <tr key={exam.exam_key}>
                          <td data-label={t('exams.examKey')}>
                            {exam.id ? (
                              <Link to={`/exams/${exam.id}`} className="mono ltr">
                                {exam.exam_key}
                              </Link>
                            ) : (
                              <Ltr className="mono">{exam.exam_key}</Ltr>
                            )}
                          </td>
                          <td data-label={t('import.action')}>
                            <span className={`badge badge--${exam.action === 'created' ? 'success' : 'info'}`}>
                              {exam.action === 'created' ? t('import.created') : t('import.updated')}
                            </span>
                          </td>
                          <td data-label={t('app.status')}>{t(`examStatus.${exam.status}`, { defaultValue: exam.status })}</td>
                          <td className="num" data-label={t('import.questionCount')}>
                            <Credits value={exam.question_count} />
                          </td>
                          <td className="num" data-label={t('import.leafCount')}>
                            <Credits value={exam.leaf_question_count} />
                          </td>
                          <td className="num" data-label={t('import.leafMarks')}>
                            {exam.leaf_marks == null ? '—' : formatMarks(exam.leaf_marks, i18n.language)}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          ) : null}

          <ProblemTable
            title={t('import.errors')}
            rows={state.errors}
            tone="danger"
            columns={problemColumns}
          />
          <ProblemTable
            title={t('import.warnings')}
            rows={state.warnings}
            tone="warning"
            columns={problemColumns}
          />
          {state.ok && !state.warnings.length ? (
            <p className="muted" style={{ fontSize: 'var(--text-sm)' }}>{t('import.noWarnings')}</p>
          ) : null}
        </>
      ) : null}
    </div>
  );
}