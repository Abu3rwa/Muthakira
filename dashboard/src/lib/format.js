const localeOf = (language) => (language === 'ar' ? 'ar-SD' : 'en-GB');

export function formatNumber(value, language, options = {}) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) return '—';
  return new Intl.NumberFormat(localeOf(language), options).format(Number(value));
}

export function formatCredits(value, language) {
  return formatNumber(value, language, { maximumFractionDigits: 0 });
}

export function formatMoney(value, language) {
  if (value === null || value === undefined) return '—';
  return `${formatNumber(value, language, { maximumFractionDigits: 0 })} SDG`;
}

export function formatMarks(value, language) {
  if (value === null || value === undefined) return '—';
  return formatNumber(value, language, { maximumFractionDigits: 2 });
}

export function formatDate(value, language, { withTime = true } = {}) {
  if (!value) return '—';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '—';
  return new Intl.DateTimeFormat(localeOf(language), {
    year: 'numeric',
    month: 'short',
    day: '2-digit',
    ...(withTime ? { hour: '2-digit', minute: '2-digit' } : {}),
  }).format(date);
}

export function formatRelative(value, language) {
  if (!value) return '—';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '—';
  const diffMinutes = Math.round((date.getTime() - Date.now()) / 60000);
  const formatter = new Intl.RelativeTimeFormat(localeOf(language), { numeric: 'auto' });
  const steps = [
    ['year', 525600],
    ['month', 43200],
    ['day', 1440],
    ['hour', 60],
    ['minute', 1],
  ];
  for (const [unit, minutes] of steps) {
    if (Math.abs(diffMinutes) >= minutes) return formatter.format(Math.round(diffMinutes / minutes), unit);
  }
  return formatter.format(0, 'minute');
}

export function formatBytes(value, language) {
  if (!value) return '—';
  const units = ['B', 'KB', 'MB', 'GB'];
  let size = Number(value);
  let unit = 0;
  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit += 1;
  }
  return `${formatNumber(size, language, { maximumFractionDigits: unit === 0 ? 0 : 1 })} ${units[unit]}`;
}

export const shortId = (value) => (value ? String(value).slice(-6) : '—');
