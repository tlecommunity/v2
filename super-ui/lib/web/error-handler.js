import _ from 'lodash';

import WindowActions from './actions/window';

let Messenger = () => {
  let M = window.Messenger;

  return M({
    theme: 'block',
    extraClasses: 'messenger-fixed messenger-on-top',
    maxMessages: 1,
  });
};

import log from '../log';

const messageDefaults = {
  showCloseButton: true,
  hideAfter: 10,
};

let handleDefaults = (options) => {
  return _.merge({}, messageDefaults, options);
};

WindowActions.error.listen((message) => {
  log.error(message);

  window.alert(message);

  // Messenger().post(handleDefaults({
  //   message,
  //   type: 'error'
  // }))
});
