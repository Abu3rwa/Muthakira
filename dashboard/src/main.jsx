import React from 'react';
import { createRoot } from 'react-dom/client';
import { Provider } from 'react-redux';
import { BrowserRouter } from 'react-router-dom';
import { store } from './app/store.js';
import { bootstrap } from './features/auth/authSlice.js';
import App from './App.jsx';
import './i18n/index.js';
import './styles/tokens.css';
import './styles/base.css';
import './styles/layout.css';
import './styles/components.css';

async function start() {
  if (import.meta.env.VITE_MOCK === '1') {
    const { installMockApi } = await import('./mocks/index.js');
    installMockApi();
  }

  store.dispatch(bootstrap());

  createRoot(document.getElementById('root')).render(
    <React.StrictMode>
      <Provider store={store}>
        <BrowserRouter>
          <App />
        </BrowserRouter>
      </Provider>
    </React.StrictMode>,
  );
}

start();