import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import Icon from './Icon.jsx';

export default function SearchInput({ value = '', onSearch, placeholder, label, delay = 400 }) {
  const { t } = useTranslation();
  const [text, setText] = useState(value);
  const timer = useRef(null);
  const lastSent = useRef(value);

  useEffect(() => {
    setText(value);
    lastSent.current = value;
  }, [value]);

  useEffect(() => () => clearTimeout(timer.current), []);

  const change = (next) => {
    setText(next);
    clearTimeout(timer.current);
    timer.current = setTimeout(() => {
      if (lastSent.current === next) return;
      lastSent.current = next;
      onSearch(next);
    }, delay);
  };

  const clear = () => {
    clearTimeout(timer.current);
    setText('');
    lastSent.current = '';
    onSearch('');
  };

  return (
    <div className="search">
      <span className="search__icon">
        <Icon name="search" size={16} />
      </span>
      <input
        className="input"
        type="search"
        value={text}
        placeholder={placeholder}
        aria-label={label ?? placeholder ?? t('app.search')}
        onChange={(event) => change(event.target.value)}
      />
      {text ? (
        <span className="search__clear">
          <button type="button" className="icon-btn" onClick={clear} aria-label={t('app.reset')}>
            <Icon name="close" size={14} />
          </button>
        </span>
      ) : null}
    </div>
  );
}