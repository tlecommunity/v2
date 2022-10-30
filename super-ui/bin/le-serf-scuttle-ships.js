import program from 'commander';
import _ from 'lodash';
import runner from '../lib/cli/task-runner';

program
  .option('-p --planet [name]', 'planet(s) to train spies on')
  .option('-t --type [name]', `type of ships to scuttle`)
  .parse(process.argv);

let options = _.pick(program, ['planet', 'type']);
runner.run('scuttle-ships', options);
