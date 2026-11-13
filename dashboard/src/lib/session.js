const KEY = 'mothakira.session';

const storage = () => (typeof localStorage === 'undefined' ? null : localStorage);

export function readSession() {
  try {
    const raw = storage()?.getItem(KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    return parsed && parsed.accessToken ? parsed : null;
  } catch {
    return null;
  }
}

export function writeSession(session) {
  try {
    storage()?.setItem(KEY, JSON.stringify(session));
  } catch {
    /* storage unavailable: the session lives in memory for this tab only */
  }
}

export function clearSession() {
  try {
    storage()?.removeItem(KEY);
  } catch {
    /* ignore */
  }
}

export const SESSION_KEY = KEY;
