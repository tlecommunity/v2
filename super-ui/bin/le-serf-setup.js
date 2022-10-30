import log from '../lib/log';

import config from '../lib/cli/config';

config.setup(() => {
  log.info('Successfully set up the config file');
});
