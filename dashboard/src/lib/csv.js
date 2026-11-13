export const MAX_CSV_BYTES = 2_000_000;

export function readCsvFile(file) {
  return new Promise((resolve, reject) => {
    if (!file) return reject(new Error('NO_FILE'));
    if (file.size > MAX_CSV_BYTES) return reject(new Error('FILE_TOO_LARGE'));
    if (!/\.csv$/i.test(file.name)) return reject(new Error('NOT_CSV'));
    const reader = new FileReader();
    reader.onerror = () => reject(new Error('READ_FAILED'));
    reader.onload = () => resolve(String(reader.result ?? ''));
    reader.readAsText(file, 'UTF-8');
  });
}
