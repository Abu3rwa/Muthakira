import { useTranslation } from 'react-i18next';
import Icon from './Icon.jsx';

export default function Pagination({ total, limit, skip, onChange, loading = false }) {
  const { t } = useTranslation();
  if (!total) return null;
  const from = Math.min(skip + 1, total);
  const to = Math.min(skip + limit, total);
  const pages = Math.max(1, Math.ceil(total / limit));
  const page = Math.floor(skip / limit) + 1;

  return (
    <div className="table-foot">
      <span>{t('app.showing', { from, to, total })}</span>
      <div className="pagination">
        <button
          type="button"
          className="btn btn--outline btn--sm"
          disabled={loading || skip <= 0}
          onClick={() => onChange(Math.max(0, skip - limit))}
        >
          <Icon name="chevronLeft" className="flip-rtl" />
          {t('app.previous')}
        </button>
        <span className="pagination__page">{t('app.page', { page, pages })}</span>
        <button
          type="button"
          className="btn btn--outline btn--sm"
          disabled={loading || skip + limit >= total}
          onClick={() => onChange(skip + limit)}
        >
          {t('app.next')}
          <Icon name="chevronRight" className="flip-rtl" />
        </button>
      </div>
    </div>
  );
}