export function errorMessage(t, error) {
  if (!error) return '';
  const code = error.code || 'INTERNAL_ERROR';
  return t(`errors.${code}`, { defaultValue: t('errors.fallback', { code }), code });
}

export function errorDetails(error) {
  const details = error?.details;
  if (!details) return [];
  if (Array.isArray(details)) {
    return details.map((item) =>
      typeof item === 'string' ? item : `${item.path ?? item.field ?? ''} ${item.message ?? ''}`.trim(),
    );
  }
  if (Array.isArray(details.problems)) {
    return details.problems
      .map((problem) => {
        if (problem == null) return '';
        if (typeof problem === 'string') return problem;
        const path = problem.path ?? problem.field ?? '';
        const text = problem.message ?? problem.code ?? '';
        return [path, text].filter(Boolean).join(' — ');
      })
      .filter(Boolean);
  }
  return [];
}

export function fieldErrors(error) {
  const details = error?.details;
  if (!Array.isArray(details)) return {};
  const map = {};
  for (const item of details) {
    if (item?.path) map[String(item.path)] = item.message;
  }
  return map;
}