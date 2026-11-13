export default function Badge({ tone = 'neutral', plain = false, children, title }) {
  return (
    <span className={`badge badge--${tone}${plain ? ' badge--plain' : ''}`} title={title}>
      {children}
    </span>
  );
}