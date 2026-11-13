export default function Tabs({ items, value, onChange, ariaLabel }) {
  return (
    <div className="tabs" role="tablist" aria-label={ariaLabel}>
      {items.map((item) => (
        <button
          key={item.value}
          type="button"
          role="tab"
          aria-selected={value === item.value}
          className={`tab ${value === item.value ? 'tab--active' : ''}`}
          onClick={() => onChange(item.value)}
        >
          {item.label}
          {item.count !== undefined ? <span className="tab__count num">{item.count}</span> : null}
        </button>
      ))}
    </div>
  );
}