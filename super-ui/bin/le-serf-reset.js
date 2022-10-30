import log from '../lib/log';

import config from '../lib/cli/config';

config.clear(() => {
  log.info('Successfully cleared the config file');
});
