import lacuna from '../client';
import legacyLacuna from '../lacuna';
import * as App from './app';

import EmpireStore from './stores/empire';

import ConfigStore from './stores/config';
import SessionStore from './stores/session';

let freshLogin = async (config) => {
  if (!config.empire) {
    App.error('Please enter an empire');
    return;
  } else if (!config.password) {
    App.error('Please enter a password');
    return;
  } else if (!config.server) {
    App.error('Please select a server to play on');
    return;
  }

  // TODO: error handling
  // App.error(message);
  // App.navigate('/login');
  lacuna.config.serverUrl = config.server;

  await lacuna.authenticate(config.empire, config.password);
  await EmpireStore.getStatus();

  const session = lacuna.session.get();

  legacyLacuna.init(config, session); // TODO: legacy, pls remove
  SessionStore.set(session);
  ConfigStore.set(config);
  App.navigate('/task-selection');
};

let handleInitialLogin = () => {
  let config = ConfigStore.get();
  let session = SessionStore.get();

  if (!config || !config.empire || !config.password) {
    App.navigate('/login');
    return;
  }

  freshLogin(config, session);
};

export { freshLogin, handleInitialLogin };
