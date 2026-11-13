import { beforeEach, describe, expect, it, vi } from 'vitest';
import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import ExamImportPage from './ExamImportPage.jsx';
import { ToastHost } from '../components/Toasts.jsx';
import {
  authenticatedState,
  english,
  errorResponse,
  initOf,
  jsonResponse,
  renderWithProviders,
  stubFetch,
  urlOf,
} from '../test/helpers.jsx';

const EXAMS_CSV =
  'exam_key,language,subject,class_level,exam_year,session,title_ar\n' +
  '2026-ar-math,ar,math,grade9,2026,first,امتحان الرياضيات\n';
const QUESTIONS_CSV =
  'exam_key,path,type,marks,prompt_ar\n' + '2026-ar-math,q1,mcq,1,ما هو ناتج ٢ + ٢؟\n';

const csvFile = (name, text) => new File([text], name, { type: 'text/csv' });

const importProblem = (overrides = {}) => ({
  file: 'questions.csv',
  line: 3,
  field: 'marks',
  message: 'marks must be a positive number',
  ...overrides,
});

const paper = (overrides = {}) => ({
  exam_key: '2026-ar-math',
  action: 'created',
  status: 'draft',
  question_count: 1,
  leaf_question_count: 1,
  leaf_marks: 1,
  ...overrides,
});

function renderImport() {
  return renderWithProviders(
    <>
      <ExamImportPage />
      <ToastHost />
    </>,
    { preloadedState: authenticatedState() },
  );
}

const validateButton = () => screen.getByRole('button', { name: 'Validate (dry run)' });
const applyButton = () => screen.getByRole('button', { name: 'Apply import' });

async function pickBothFiles() {
  await userEvent.upload(screen.getByLabelText('exams.csv'), csvFile('exams.csv', EXAMS_CSV));
  await userEvent.upload(screen.getByLabelText('questions.csv'), csvFile('questions.csv', QUESTIONS_CSV));
  await waitFor(() => expect(validateButton()).toBeEnabled());
}

const bodyOf = (call) => JSON.parse(initOf(call).body);

beforeEach(async () => {
  await english();
});

describe('ExamImportPage', () => {
  it('offers the three sample CSV files for download', async () => {
    stubFetch(() => jsonResponse({}));
    renderImport();

    for (const name of ['exams.csv', 'stimuli.csv', 'questions.csv']) {
      const link = screen.getByRole('link', { name });
      expect(link).toHaveAttribute('href', `/samples/${name}`);
      expect(link).toHaveAttribute('download');
    }
  });

  it('copies the full import prompt to the clipboard', async () => {
    stubFetch(() => jsonResponse({}));
    const writeText = vi.fn().mockResolvedValue(undefined);
    Object.defineProperty(navigator, 'clipboard', { configurable: true, value: { writeText } });
    renderImport();

    await userEvent.click(screen.getByRole('button', { name: 'Copy AI prompt' }));

    expect(writeText).toHaveBeenCalledTimes(1);
    const prompt = writeText.mock.calls[0][0];
    for (const needle of [
      'exams.csv',
      'stimuli.csv',
      'questions.csv',
      'Required columns: exam_key',
      'The marks of all leaf questions must equal total_marks',
      'key_status',
      'Paste the full exam paper here',
    ]) {
      expect(prompt).toContain(needle);
    }
    expect(
      await screen.findByText('Prompt copied to the clipboard.', { selector: '.toast__body strong' }),
    ).toBeInTheDocument();
  });

  it('gates validation on both files and lists every dry-run error with file, line, field and message', async () => {
    const fetchMock = stubFetch(() =>
      errorResponse(422, 'EXAM_IMPORT_INVALID', {
        errors: [importProblem()],
        warnings: [importProblem({ line: 2, field: 'topic_key', message: 'unknown topic_key "algebra"' })],
      }),
    );
    renderImport();

    expect(validateButton()).toBeDisabled();
    expect(applyButton()).toBeDisabled();
    expect(screen.getByText('Choose exams.csv and questions.csv first.')).toBeInTheDocument();

    await pickBothFiles();
    expect(applyButton()).toBeDisabled();

    await userEvent.click(validateButton());

    const errors = await screen.findByText('Errors');
    const errorTable = within(errors.closest('.card'));
    expect(errorTable.getByText('File')).toBeInTheDocument();
    expect(errorTable.getByText('Line')).toBeInTheDocument();
    expect(errorTable.getByText('Field')).toBeInTheDocument();
    expect(errorTable.getByText('Message')).toBeInTheDocument();
    expect(errorTable.getByText('questions.csv')).toBeInTheDocument();
    expect(errorTable.getByText('3')).toBeInTheDocument();
    expect(errorTable.getByText('marks')).toBeInTheDocument();
    expect(errorTable.getByText('marks must be a positive number')).toBeInTheDocument();

    const warnings = within(screen.getByText('Warnings').closest('.card'));
    expect(warnings.getByText('unknown topic_key "algebra"')).toBeInTheDocument();

    expect(applyButton()).toBeDisabled();
    expect(screen.getAllByText('Fix every error before applying.').length).toBeGreaterThan(0);
    expect(urlOf(fetchMock.mock.calls[0])).toBe('/api/v1/admin/exams/import');
    expect(bodyOf(fetchMock.mock.calls[0])).toEqual({
      exams: EXAMS_CSV,
      questions: QUESTIONS_CSV,
      dryRun: true,
    });
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it('enables Apply only after a clean dry run, then applies with dryRun false', async () => {
    const fetchMock = stubFetch((...call) =>
      bodyOf(call).dryRun
        ? jsonResponse({ warnings: [], exams: [paper()] })
        : jsonResponse({ warnings: [], exams: [paper({ id: '000000000000000000000041' })] }, 201),
    );
    renderImport();
    await pickBothFiles();

    await userEvent.click(validateButton());

    expect(await screen.findByText('No errors. You can apply this import.')).toBeInTheDocument();
    expect(screen.getByText('Dry run finished. Nothing was written.', { selector: '.toast__body strong' })).toBeInTheDocument();
    expect(applyButton()).toBeEnabled();
    expect(fetchMock).toHaveBeenCalledTimes(1);

    await userEvent.click(applyButton());

    await waitFor(() => expect(fetchMock).toHaveBeenCalledTimes(2));
    expect(bodyOf(fetchMock.mock.calls[1])).toEqual({
      exams: EXAMS_CSV,
      questions: QUESTIONS_CSV,
      dryRun: false,
    });
    expect(
      await screen.findByText('Import applied.', { selector: '.toast__body strong' }),
    ).toBeInTheDocument();
    expect(screen.getByRole('link', { name: '2026-ar-math' })).toHaveAttribute(
      'href',
      '/exams/000000000000000000000041',
    );
  });

  it('allows applying when the dry run reports warnings but no errors', async () => {
    stubFetch(() =>
      jsonResponse({
        warnings: [importProblem({ field: 'answer_key', message: 'no answer_key for a paid paper' })],
        exams: [paper()],
      }),
    );
    renderImport();
    await pickBothFiles();

    await userEvent.click(validateButton());

    const warningsHeading = await screen.findByText('Warnings');
    const warnings = within(warningsHeading.closest('.card'));
    expect(warnings.getByText('no answer_key for a paid paper')).toBeInTheDocument();
    expect(screen.queryByText('Errors')).not.toBeInTheDocument();
    expect(applyButton()).toBeEnabled();
  });

  it('rejects a non-CSV file with a readable reason and keeps validation disabled', async () => {
    const fetchMock = stubFetch(() => jsonResponse({}));
    renderImport();

    await userEvent.upload(
      screen.getByLabelText('exams.csv'),
      new File(['not a csv'], 'exams.txt', { type: 'text/plain' }),
      { applyAccept: false },
    );

    expect(await screen.findByText('Choose a .csv file.')).toBeInTheDocument();
    expect(validateButton()).toBeDisabled();
    expect(fetchMock).not.toHaveBeenCalled();
  });
});