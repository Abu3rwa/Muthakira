import { useTranslation } from 'react-i18next';
import Pagination from './Pagination.jsx';
import { EmptyState, ErrorState, SkeletonRows } from './States.jsx';

export default function ListPanel({
  state,
  columns,
  rowKey = (row) => row.id,
  onRowClick,
  emptyText,
  emptyIcon,
  onRetry,
  onPage,
  selection,
  responsive = true,
  footerNote,
}) {
  const { t } = useTranslation();
  const { status, items, total, limit, skip, error } = state;
  const loading = status === 'loading';
  const showSkeleton = loading && items.length === 0;
  const allSelected = selection && items.length > 0 && items.every((row) => selection.selected.includes(rowKey(row)));

  if (status === 'error' && items.length === 0) {
    return (
      <div className="card">
        <ErrorState error={error} onRetry={onRetry} />
      </div>
    );
  }

  if (status === 'ready' && items.length === 0) {
    return (
      <div className="card">
        <EmptyState text={emptyText} icon={emptyIcon} />
      </div>
    );
  }

  return (
    <>
      {status === 'error' ? (
        <div className="notice notice--danger" role="alert">
          <span className="grow">{t('app.errorHint')}</span>
          {onRetry ? (
            <button type="button" className="btn btn--outline btn--sm" onClick={onRetry}>
              {t('app.retry')}
            </button>
          ) : null}
        </div>
      ) : null}
      <div className="table-wrap" aria-busy={loading}>
        {showSkeleton ? (
          <SkeletonRows columns={columns.length + (selection ? 1 : 0)} />
        ) : (
          <table className={`table${responsive ? ' table--responsive' : ''}`}>
            <thead>
              <tr>
                {selection ? (
                  <th className="cell-select">
                    <input
                      type="checkbox"
                      checked={Boolean(allSelected)}
                      aria-label={t('app.selectAll')}
                      onChange={() =>
                        allSelected
                          ? selection.onClear()
                          : selection.onSelectAll(items.map((row) => rowKey(row)))
                      }
                    />
                  </th>
                ) : null}
                {columns.map((column) => (
                  <th key={column.key} className={column.align ?? ''} style={column.width ? { width: column.width } : undefined}>
                    {column.label}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {items.map((row) => {
                const key = rowKey(row);
                const selected = selection?.selected.includes(key);
                return (
                  <tr
                    key={key}
                    className={`${onRowClick ? 'row-clickable' : ''}${selected ? ' row-selected' : ''}`}
                    onClick={onRowClick ? () => onRowClick(row) : undefined}
                  >
                    {selection ? (
                      <td className="cell-select" onClick={(event) => event.stopPropagation()}>
                        <input
                          type="checkbox"
                          checked={Boolean(selected)}
                          aria-label={`${t('app.view')} ${key}`}
                          onChange={() => selection.onToggle(key)}
                        />
                      </td>
                    ) : null}
                    {columns.map((column) => (
                      <td key={column.key} className={column.align ?? ''} data-label={column.label}>
                        {column.render ? column.render(row) : (row[column.key] ?? t('app.none'))}
                      </td>
                    ))}
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>
      {onPage ? (
        <Pagination total={total} limit={limit} skip={skip} onChange={onPage} loading={loading} />
      ) : footerNote ? (
        <div className="table-foot">{footerNote}</div>
      ) : null}
    </>
  );
}