// This test repeatedly calls `empire.getStatus()`` so as to test retrying
// calls when we hit the 60 clicks per minute limit.

import lacuna from './test-instance';
import log from '../../lib/log';

import Promise from 'bluebird';

let num = 0;

let getStatus = () => {
  num += 1;
  log.info(`Getting status (${num})`);
  return lacuna.empire.getStatus({}).then(getStatus);
};

// Start it off
lacuna
  .authenticate()
  .then(() => {
    // Spam the server real good.
    return Promise.all([
      lacuna.empire.getStatus({}).then(getStatus),
      lacuna.empire.getStatus({}).then(getStatus),
      lacuna.empire.getStatus({}).then(getStatus),
      lacuna.empire.getStatus({}).then(getStatus),
      lacuna.empire.getStatus({}).then(getStatus),
    ]);
  })
  .catch((err) => {
    log.error(err);
  });
