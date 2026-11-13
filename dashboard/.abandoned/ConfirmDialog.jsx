import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { closeConfirm } from '../features/ui/uiSlice.js';
import Button from './Button.jsx';
import { Modal } from './Overlay.jsx';

export default function ConfirmDialog() {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const confirm = useAppSelector((state) => state.ui.confirm);
  if (!confirm) return null;

  const close = () => dispatch(closeConfirm());

  return (
    <Modal
      open
      title={confirm.title}
      subtitle={confirm.subtitle}
      onClose={close}
      footer={
        <>
          <Button variant="ghost" onClick={close}>
            {t('common.actions.cancel')}
          </Button>
          <Button
            variant={confirm.tone === 'danger' ? 'danger' : 'primary'}
            onClick={() => {
              confirm.onConfirm?.();
              close();
            }}
          >
            {confirm.confirmLabel ?? t('common.actions.confirm')}
          </Button>
        </>
      }
    >
      {confirm.body ? <p className="soft">{confirm.body}</p> : null}
    </Modal>
  );
}