import { useTranslation } from 'react-i18next';
import Icon from './Icon.jsx';
import Pagination from './Pagination.jsx';
import { EmptyState, ErrorState, SkeletonRows } from './states/States.jsx';

export default function DataTable({
  columns,
  rows,
  rowKey = 'id',
  loading = false,
  error = null,
  empty,
  onRetry,
  onRowClick,
  selectable = false,
  selected = [],
  onToggle,
  onToggleAll,
  sort,
  onSort,
  pagination,
  responsive = true,
}) {
  const { t } = useTranslation();
  const span = columns.length + (selectable ? 1 : 0);
  const allSelected = selectable && rows.length > 0 && rows.every((row) => selected.includes(row[rowKey]));

  const body = () => {
    if (error) {
      return (
        <tr>
          <td colSpan={span}>
            <ErrorState error={error} onRetry={onRetry} />
          </td>
        </tr>
      );
    }
    if (loading && rows.length === 0) {
      return (
        <tr>
          <td colSpan={span} style={{ padding: 0 }}>
            <SkeletonRows columns={Math.min(span, 6)} />
          </td>
        </tr>
      );
    }
    if (rows.length === 0) {
      return (
        <tr>
          <td colSpan={span}>
            <EmptyState title={empty?.title} text={empty?.text} />
          </td>
        </tr>
      );
    }
    return rows.map((row) => {
      const id = row[rowKey];
      const isSelected = selected.includes(id);
      return (
        <tr
          key={id}
          className={[onRowClick ? 'row-clickable' : '', isSelected ? 'row-selected' : '']
            .filter(Boolean)
            .join(' ')}
          onClick={onRowClick ? () => onRowClick(row) : undefined}
        >
          {selectable ? (
            <td className="cell-select" data-label={t('common.actions.selectAll')}>
              <input
                type="checkbox"
                checked={isSelected}
                aria-label={String(id)}
                onClick={(event) => event.stopPropagation()}
                onChange={() => onToggle(id)}
              />
            </td>
          ) : null}
          {columns.map((column) => (
            <td
              key={column.key}
              data-label={column.label}
              className={[column.align === 'num' ? 'num' : '', column.align === 'center' ? 'center' : '']
                .filter(Boolean)
                .join(' ')}
              style={column.width ? { width: column.width } : undefined}
            >
              {column.render ? column.render(row) : (row[column.key] ?? '—')}
            </td>
          ))}
        </tr>
      );
    });
  };

  return (
    <>
      <div className="table-wrap">
        <table className={`table ${responsive ? 'table--responsive' : ''}`}>
          <thead>
            <tr>
              {selectable ? (
                <th className="cell-select">
                  <input
                    type="checkbox"
                    checked={allSelected}
                    aria-label={t('common.actions.selectAll')}
                    onChange={() => onToggleAll(allSelected ? [] : rows.map((row) => row[rowKey]))}
                  />
                </th>
              ) : null}
              {columns.map((column) => {
                const active = sort?.key === column.key;
                return (
                  <th
                    key={column.key}
                    className={[
                      column.align === 'num' ? 'num' : '',
                      column.align === 'center' ? 'center' : '',
                      column.sortable ? 'sortable' : '',
                    ]
                      .filter(Boolean)
                      .join(' ')}
                    style={column.width ? { width: column.width } : undefined}
                    aria-sort={active ? (sort.dir === 'asc' ? 'ascending' : 'descending') : undefined}
                    onClick={column.sortable && onSort ? () => onSort(column.key) : undefined}
                  >
                    {column.label}
                    {column.sortable ? (
                      <span className="sort-caret">
                        <Icon name={active && sort.dir === 'asc' ? 'chevronUp' : 'chevronDown'} size={12} />
                      </span>
                    ) : null}
                  </th>
                );
              })}
            </tr>
          </thead>
          <tbody>{body()}</tbody>
        </table>
      </div>
      {pagination ? <Pagination {...pagination} /> : null}
    </>
  );
}