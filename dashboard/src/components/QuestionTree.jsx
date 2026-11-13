import { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { ACCESS_TONES, KEY_STATUS_TONES } from '../lib/constants.js';
import { formatMarks } from '../lib/format.js';
import Badge from './Badge.jsx';
import Icon from './Icon.jsx';
import { EmptyState } from './States.jsx';

const LETTERS = [
  ['أ', 'ب', 'ج', 'د', 'ه', 'و', 'ز', 'ح', 'ط', 'ي'],
  ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'],
];

function letterIndex(value) {
  const raw = String(value ?? '').trim().replace(/[.\sـ]/g, '');
  const bare = raw === 'ا' ? 'أ' : raw;
  for (const alphabet of LETTERS) {
    const index = alphabet.indexOf(bare);
    if (index >= 0) return index;
  }
  return -1;
}

function keyLetterIndexes(key) {
  const list = Array.isArray(key) ? key : [key];
  return new Set(list.map(letterIndex).filter((index) => index >= 0));
}

function ValueBlock({ value, emptyText }) {
  if (value === null || value === undefined || value === '') {
    return <span className="muted">{emptyText}</span>;
  }
  if (typeof value === 'object') {
    return <pre className="code-block">{JSON.stringify(value, null, 2)}</pre>;
  }
  return <span className="mono ltr">{String(value)}</span>;
}

function Detail({ label, children }) {
  return (
    <div className="field">
      <span className="field__label">{label}</span>
      <div>{children}</div>
    </div>
  );
}

function QuestionNode({ node, childrenOf, open, toggle, language }) {
  const { t } = useTranslation();
  const isOpen = open.has(node.id);
  const kids = childrenOf(node.id);
  const keyIndexes = keyLetterIndexes(node.key);
  const letters = language === 'ar' ? LETTERS[0] : LETTERS[1];

  return (
    <div className={`tree__node${node.is_container ? ' tree__node--container' : ''}`}>
      <button
        type="button"
        className="tree__head"
        aria-expanded={isOpen}
        onClick={() => toggle(node.id)}
      >
        <Icon name={isOpen ? 'chevronDown' : 'chevronRight'} size={14} className={isOpen ? '' : 'flip-rtl'} />
        <span className="tree__path ltr">{node.path}</span>
        <span className={`tree__text${isOpen ? '' : ' truncate'}`}>{node.text}</span>
        <span className="tree__tags">
          <Badge tone="neutral" plain>
            {t(`questionType.${node.type}`, { defaultValue: node.type })}
          </Badge>
          {!node.is_container ? (
            <Badge tone={ACCESS_TONES[node.access] ?? 'neutral'} plain>
              {t(`access.${node.access}`, { defaultValue: node.access })}
            </Badge>
          ) : null}
          {!node.is_container ? (
            <Badge tone={KEY_STATUS_TONES[node.key_status] ?? 'neutral'} plain>
              {t(`keyStatus.${node.key_status}`, { defaultValue: node.key_status })}
            </Badge>
          ) : null}
          <span className="mono num muted">{formatMarks(node.marks, language)}</span>
        </span>
      </button>

      {isOpen ? (
        <div className="tree__body">
          <div className="row wrap" style={{ gap: 'var(--space-2)' }}>
            {node.practice_eligible ? <Badge tone="acid">{t('exams.practiceEligible')}</Badge> : null}
            {node.marking_method ? (
              <Badge tone="info" plain>
                {t(`markingMethod.${node.marking_method}`, { defaultValue: node.marking_method })}
              </Badge>
            ) : null}
            {node.difficulty ? (
              <span className="muted" style={{ fontSize: 'var(--text-xs)' }}>
                {t('exams.difficulty')}: {node.difficulty}/5
              </span>
            ) : null}
            {node.key_version ? (
              <span className="muted" style={{ fontSize: 'var(--text-xs)' }}>
                {t('exams.keyVersion')}: {node.key_version}
              </span>
            ) : null}
          </div>

          {node.options?.length ? (
            <Detail label={t('exams.options')}>
              <div className="option-list">
                {node.options.map((option, index) => (
                  <div key={index} className={`option${keyIndexes.has(index) ? ' option--key' : ''}`}>
                    <span className="option__label">{letters[index] ?? index + 1}</span>
                    <span className="grow">{option}</span>
                    {keyIndexes.has(index) ? <Icon name="check" size={13} /> : null}
                  </div>
                ))}
              </div>
            </Detail>
          ) : null}

          {!node.is_container ? (
            <Detail label={t('exams.key')}>
              <ValueBlock value={node.key} emptyText={t('exams.noKey')} />
            </Detail>
          ) : null}

          {node.accepted_alternatives?.length ? (
            <Detail label={t('exams.acceptedAlternatives')}>
              <div className="row wrap">
                {node.accepted_alternatives.map((alternative, index) => (
                  <span key={index} className="chip">
                    {alternative}
                  </span>
                ))}
              </div>
            </Detail>
          ) : null}

          {node.criteria?.length ? (
            <Detail label={t('exams.criteria')}>
              <ul className="stack stack--tight">
                {node.criteria.map((criterion, index) => (
                  <li key={index} className="row row--between">
                    <span className="grow">{criterion.text}</span>
                    <span className="mono num">{formatMarks(criterion.marks, language)}</span>
                  </li>
                ))}
              </ul>
            </Detail>
          ) : null}

          {node.model_answer ? (
            <Detail label={t('exams.modelAnswer')}>
              <p style={{ whiteSpace: 'pre-wrap' }}>{node.model_answer}</p>
            </Detail>
          ) : null}

          {node.explanation ? (
            <Detail label={t('exams.explanation')}>
              <p style={{ whiteSpace: 'pre-wrap' }}>{node.explanation}</p>
            </Detail>
          ) : null}

          {node.normalisation?.length ? (
            <Detail label={t('exams.normalisation')}>
              <div className="row wrap">
                {node.normalisation.map((flag) => (
                  <span key={flag} className="chip mono">
                    {flag}
                  </span>
                ))}
              </div>
            </Detail>
          ) : null}

          {node.topic_keys?.length ? (
            <Detail label={t('exams.topicTags')}>
              <div className="row wrap">
                {node.topic_keys.map((key) => (
                  <span key={key} className="chip mono">
                    {key}
                  </span>
                ))}
              </div>
            </Detail>
          ) : null}
        </div>
      ) : null}

      {isOpen && kids.length ? (
        <div className="tree__children">
          {kids.map((child) => (
            <QuestionNode
              key={child.id}
              node={child}
              childrenOf={childrenOf}
              open={open}
              toggle={toggle}
              language={language}
            />
          ))}
        </div>
      ) : null}
    </div>
  );
}

export default function QuestionTree({ questions = [], language = 'ar' }) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(() => new Set());

  const byParent = useMemo(() => {
    const map = new Map();
    for (const question of questions) {
      const key = question.parent_id ?? 'root';
      if (!map.has(key)) map.set(key, []);
      map.get(key).push(question);
    }
    for (const list of map.values()) list.sort((a, b) => a.sort_order - b.sort_order);
    return map;
  }, [questions]);

  const signature = questions.map((question) => question.id).join(',');

  useEffect(() => {
    setOpen(new Set(questions.filter((question) => question.is_container).map((question) => question.id)));
  }, [signature]);

  const childrenOf = (id) => byParent.get(id ?? 'root') ?? [];
  const roots = childrenOf(null);

  if (!questions.length) return <EmptyState text={t('exams.noQuestions')} icon="paper" />;

  const toggle = (id) =>
    setOpen((current) => {
      const next = new Set(current);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });

  return (
    <div className="stack">
      <div className="row wrap">
        <button
          type="button"
          className="btn btn--outline btn--sm"
          onClick={() => setOpen(new Set(questions.map((question) => question.id)))}
        >
          <Icon name="plus" size={13} />
          {t('app.expandAll')}
        </button>
        <button type="button" className="btn btn--outline btn--sm" onClick={() => setOpen(new Set())}>
          <Icon name="minus" size={13} />
          {t('app.collapseAll')}
        </button>
        <span className="grow" />
        <span className="muted" style={{ fontSize: 'var(--text-sm)' }}>
          {t('app.rows', { count: questions.length })}
        </span>
      </div>
      <div className="tree">
        {roots.map((node) => (
          <QuestionNode
            key={node.id}
            node={node}
            childrenOf={childrenOf}
            open={open}
            toggle={toggle}
            language={language}
          />
        ))}
      </div>
    </div>
  );
}