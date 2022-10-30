import program from 'commander';
import _ from 'lodash';
import runner from '../lib/cli/task-runner';

program.option('-p --planet <name>', 'planet(s) to look at').parse(process.argv);

let options = _.pick(program, ['planet']);
runner.run('docked-ships', options);
