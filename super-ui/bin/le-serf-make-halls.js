import program from 'commander';
import _ from 'lodash';

import runner from '../lib/cli/task-runner';

program.option('-p, --planet [planet name]', 'the planet to make halls on').parse(process.argv);

runner.run('make-halls', _.pick(program, ['planet']));
