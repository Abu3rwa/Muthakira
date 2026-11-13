import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { clearPackageError, createPackage, fetchPackages, updatePackage } from '../features/packages/packagesSlice.js';
import { confirmAction, toast } from '../app/feedback.js';
import Badge from '../components/Badge.jsx';
import Field from '../components/Field.jsx';
import Icon from '../components/Icon.jsx';
import ListPanel from '../components/ListPanel.jsx';
import Modal from '../components/Modal.jsx';
import { Credits, DateCell, Ltr, Money, Num } from '../components/Data.jsx';
import { InlineError } from '../components/States.jsx';

const EMPTY_FORM = { nameAr: '', nameEn: '', credits: '', price: '', sortOrder: '0', active: true };

const formOf = (pkg) => ({
  nameAr: pkg.name?.ar ?? '',
  nameEn: pkg.name?.en ?? '',
  credits: String(pkg.credits ?? ''),
  price: String(pkg.price_sdg ?? ''),
  sortOrder: String(pkg.sort_order ?? 0),
  active: Boolean(pkg.active),
});

const positiveInt = (value, max) => {
  if (!/^\d+$/.test(String(value).trim())) return false;
  const number = Number(value);
  return number >= 1 && number <= max;
};

function PackageForm({ initial, error, onSubmit }) {
  const { t } = useTranslation();
  const [form, setForm] = useState(initial);
  const [errors, setErrors] = useState({});
  const set = (key) => (event) =>
    setForm((current) => ({ ...current, [key]: key === 'active' ? event.target.checked : event.target.value }));

  const submit = (event) => {
    event.preventDefault();
    const next = {};
    if (!form.nameAr.trim() || !form.nameEn.trim()) next.name = t('packages.nameRequired');
    if (!positiveInt(form.credits, 1_000_000)) next.credits = t('packages.creditsRequired');
    if (!positiveInt(form.price, 100_000_000)) next.price = t('packages.priceRequired');
    if (!/^\d{1,5}$/.test(form.sortOrder.trim())) next.sortOrder = t('settings.invalidNumber');
    setErrors(next);
    if (Object.keys(next).length) return;
    onSubmit({
      name: { ar: form.nameAr.trim(), en: form.nameEn.trim() },
      credits: Number(form.credits),
      price_sdg: Number(form.price),
      sort_order: Number(form.sortOrder),
      active: form.active,
    });
  };

  return (
    <form id="package-form" onSubmit={submit} noValidate className="stack">
      <InlineError error={error} />
      <Field label={t('packages.nameAr')} required error={errors.name} htmlFor="pkg-ar">
        <input id="pkg-ar" className="input" value={form.nameAr} maxLength={120} onChange={set('nameAr')} />
      </Field>
      <Field label={t('packages.nameEn')} required htmlFor="pkg-en">
        <input id="pkg-en" className="input ltr" value={form.nameEn} maxLength={120} onChange={set('nameEn')} />
      </Field>
      <div className="split split--even">
        <Field label={t('packages.credits')} required error={errors.credits} htmlFor="pkg-credits">
          <input
            id="pkg-credits"
            className="input num ltr"
            type="number"
            min={1}
            max={1_000_000}
            step={1}
            value={form.credits}
            onChange={set('credits')}
          />
        </Field>
        <Field label={t('packages.price')} required error={errors.price} htmlFor="pkg-price">
          <input
            id="pkg-price"
            className="input num ltr"
            type="number"
            min={1}
            max={100_000_000}
            step={1}
            value={form.price}
            onChange={set('price')}
          />
        </Field>
      </div>
      <Field label={t('packages.sortOrder')} error={errors.sortOrder} htmlFor="pkg-sort">
        <input
          id="pkg-sort"
          className="input num ltr"
          type="number"
          min={0}
          max={10000}
          step={1}
          value={form.sortOrder}
          onChange={set('sortOrder')}
        />
      </Field>
      <label className={`check${form.active ? ' check--on' : ''}`}>
        <input type="checkbox" checked={form.active} onChange={set('active')} />
        <span className="check__box" aria-hidden="true">
          <Icon name="check" size={12} />
        </span>
        <span className="check__text">
          <strong>{t('packages.active')}</strong>
          <span>{t('packages.confirmRetireBody')}</span>
        </span>
      </label>
    </form>
  );
}

export default function PackagesPage() {
  const { t, i18n } = useTranslation();
  const dispatch = useAppDispatch();
  const state = useAppSelector((slice) => slice.packages);
  const [editing, setEditing] = useState(null);

  useEffect(() => {
    dispatch(fetchPackages({ skip: 0 }));
  }, [dispatch]);

  const close = () => {
    setEditing(null);
    dispatch(clearPackageError());
  };

  const submit = async (body) => {
    try {
      if (editing?.id) {
        await dispatch(updatePackage({ id: editing.id, ...body })).unwrap();
        dispatch(toast(t('packages.saved'), 'success'));
      } else {
        await dispatch(createPackage(body)).unwrap();
        dispatch(toast(t('packages.created'), 'success'));
      }
      close();
    } catch {
      /* the slice keeps the error for the form */
    }
  };

  const toggleActive = (pkg) => {
    const retiring = pkg.active;
    const run = async () => {
      try {
        await dispatch(updatePackage({ id: pkg.id, active: !retiring })).unwrap();
        dispatch(toast(t('packages.saved'), 'success'));
      } catch (error) {
        dispatch(toast(t('app.errorTitle'), 'danger', error?.code ?? null));
      }
    };
    if (!retiring) {
      run();
      return;
    }
    dispatch(
      confirmAction(
        {
          title: t('packages.confirmRetire'),
          body: t('packages.confirmRetireBody'),
          tone: 'danger',
          confirmLabel: t('packages.retire'),
        },
        run,
      ),
    );
  };

  const columns = [
    {
      key: 'name',
      label: t('packages.nameAr'),
      render: (row) => (
        <div className="stack stack--tight">
          <strong>{row.name?.[i18n.language] ?? row.name?.ar}</strong>
          <Ltr className="muted">{row.name?.en}</Ltr>
        </div>
      ),
    },
    { key: 'credits', label: t('packages.credits'), align: 'num', render: (row) => <Credits value={row.credits} /> },
    { key: 'price_sdg', label: t('packages.price'), align: 'num', render: (row) => <Money value={row.price_sdg} /> },
    {
      key: 'active',
      label: t('app.status'),
      render: (row) => (
        <Badge tone={row.active ? 'success' : 'neutral'}>{row.active ? t('packages.active') : t('packages.inactive')}</Badge>
      ),
    },
    { key: 'sort_order', label: t('packages.sortOrder'), align: 'num', render: (row) => <Num value={row.sort_order} /> },
    { key: 'updated_at', label: t('app.updatedAt'), render: (row) => <DateCell value={row.updated_at} /> },
    {
      key: 'actions',
      label: t('app.actions'),
      render: (row) => (
        <div className="row" style={{ gap: 4 }}>
          <button
            type="button"
            className="btn btn--outline btn--sm"
            onClick={() => {
              dispatch(clearPackageError());
              setEditing(row);
            }}
          >
            <Icon name="sliders" size={14} />
            {t('packages.edit')}
          </button>
          <button
            type="button"
            className={`btn btn--sm ${row.active ? 'btn--ghost' : 'btn--success'}`}
            onClick={() => toggleActive(row)}
            disabled={state.saving}
          >
            {row.active ? t('packages.retire') : t('packages.restore')}
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className="page">
      <div className="page-head">
        <div className="page-head__title">
          <h1>{t('packages.title')}</h1>
          <p>{t('packages.subtitle')}</p>
        </div>
        <div className="page-head__actions">
          <button
            type="button"
            className="btn btn--outline btn--sm"
            onClick={() => dispatch(fetchPackages())}
            disabled={state.status === 'loading'}
          >
            <Icon name="refresh" size={14} />
            {t('app.refresh')}
          </button>
          <button
            type="button"
            className="btn btn--primary btn--sm"
            onClick={() => {
              dispatch(clearPackageError());
              setEditing({});
            }}
          >
            <Icon name="plus" size={14} />
            {t('packages.create')}
          </button>
        </div>
      </div>

      <div className="toolbar">
        <label className="field__label" htmlFor="pkg-filter">
          {t('packages.filterActive')}
        </label>
        <select
          id="pkg-filter"
          className="select"
          value={state.filters.active}
          onChange={(event) => dispatch(fetchPackages({ filters: { active: event.target.value }, skip: 0 }))}
        >
          <option value="">{t('app.all')}</option>
          <option value="true">{t('packages.active')}</option>
          <option value="false">{t('packages.inactive')}</option>
        </select>
        <span className="grow" />
        <span className="muted" style={{ fontSize: 'var(--text-xs)' }}>{t('packages.noDelete')}</span>
      </div>

      <ListPanel
        state={state}
        columns={columns}
        onRetry={() => dispatch(fetchPackages())}
        onPage={(skip) => dispatch(fetchPackages({ skip }))}
        emptyText={t('packages.empty')}
        emptyIcon="box"
      />

      {editing ? (
        <Modal
          title={editing.id ? t('packages.editPackage') : t('packages.newPackage')}
          onClose={state.saving ? undefined : close}
          labelledBy="package-modal-title"
          footer={
            <>
              <button type="button" className="btn btn--ghost" onClick={close} disabled={state.saving}>
                {t('app.cancel')}
              </button>
              <button type="submit" form="package-form" className="btn btn--primary" disabled={state.saving}>
                {state.saving ? <span className="spinner" aria-hidden="true" /> : <Icon name="check" />}
                {state.saving ? t('app.saving') : t('app.save')}
              </button>
            </>
          }
        >
          <PackageForm
            key={editing.id ?? 'new'}
            initial={editing.id ? formOf(editing) : EMPTY_FORM}
            error={state.saveError}
            onSubmit={submit}
          />
        </Modal>
      ) : null}
    </div>
  );
}