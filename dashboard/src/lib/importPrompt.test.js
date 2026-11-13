import { describe, expect, it } from 'vitest';
import { buildImportPrompt } from './importPrompt.js';

describe('buildImportPrompt', () => {
  it('builds the complete Arabic contract with all three files and the example', () => {
    const prompt = buildImportPrompt('ar');

    expect(prompt).toContain('exams.csv');
    expect(prompt).toContain('stimuli.csv');
    expect(prompt).toContain('questions.csv');
    expect(prompt).toContain('total_marks');
    expect(prompt).toContain('key_status');
    expect(prompt).toContain('نص الورقة');
    expect(prompt).toContain('sample-2026-ar-math');
    expect(prompt).toContain('عدد العلامات يساوي عدد أجزاء المفتاح');
    expect(prompt).toContain('7,fill_blank,story-1');
    expect(prompt).not.toContain('Paper text:');
  });

  it('builds the English contract when the interface is English', () => {
    const prompt = buildImportPrompt('en');

    expect(prompt).toContain('Paper text:');
    expect(prompt).toContain('sample-2026-ar-math');
    expect(prompt).toContain('the number of markers must equal the number of key parts');
    expect(prompt).toContain('7,fill_blank,story-1');
    expect(prompt).not.toContain('نص الورقة:');
  });
});
