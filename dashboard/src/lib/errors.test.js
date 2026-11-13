import { describe, expect, it } from 'vitest';
import { errorDetails } from './errors.js';

describe('errorDetails', () => {
  it('renders publish problems as path and message instead of [object Object]', () => {
    const error = {
      code: 'EXAM_NOT_PUBLISHABLE',
      details: {
        problems: [
          { code: 'SOURCE_REQUIRED', message: 'A published paper needs a recorded source' },
          { code: 'DRAFT_KEY', message: 'Question 1.2 still has a draft key', path: '1.2' },
        ],
      },
    };

    expect(errorDetails(error)).toEqual([
      'A published paper needs a recorded source',
      '1.2 — Question 1.2 still has a draft key',
    ]);
  });

  it('falls back to the problem code when no message is present', () => {
    expect(errorDetails({ details: { problems: [{ code: 'NO_QUESTIONS' }] } })).toEqual(['NO_QUESTIONS']);
  });

  it('keeps validation details as path plus message', () => {
    const error = { details: [{ path: 'reason', message: 'String must contain at least 2 character(s)' }] };
    expect(errorDetails(error)).toEqual(['reason String must contain at least 2 character(s)']);
  });

  it('returns nothing when there are no details', () => {
    expect(errorDetails({ code: 'EXAM_NOT_FOUND' })).toEqual([]);
    expect(errorDetails(null)).toEqual([]);
  });
});
