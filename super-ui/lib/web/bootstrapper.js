import lacuna from '../lacuna';
import * as App from './app';

import EmpireStore from './stores/empire';

import ConfigStore from './stores/config';
import SessionStore from './stores/session';

let freshLogin = (config, session) => {
  if (!session) {
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
  }

  lacuna.init(config, session);
  EmpireStore.login();
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
