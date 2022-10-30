import config from './config';

import * as taskIndex from '../tasks';
const tasks = taskIndex.getTasksForPlatform('cli');
import lacuna from '../lacuna';

let run = (name, options) => {
  lacuna.init(config.load());

  lacuna.authenticate().then(() => {
    // TODO: should we save this session for later?
    tasks[name].run(options);
  });
};

export { run };
