import lacuna from '../lacuna';

import EmpireActions from './actions/empire';
import WindowActions from './actions/window';

import ConfigStore from './stores/config';
import SessionStore from './stores/session';

let freshLogin = (config, session) => {
  if (!session) {
    if (!config.empire) {
      WindowActions.error('Please enter an empire');
      return;
    } else if (!config.password) {
      WindowActions.error('Please enter a password');
      return;
    } else if (!config.server) {
      WindowActions.error('Please select a server to play on');
      return;
    }
  }

  lacuna.init(config, session);
  EmpireActions.login();
};

let handleInitialLogin = () => {
  let config = ConfigStore.getData();
  let session = SessionStore.getData();

  if (!config || !config.empire || !config.password) {
    WindowActions.navigate('/login');
    return;
  }

  freshLogin(config, session);
};

export { freshLogin, handleInitialLogin };
