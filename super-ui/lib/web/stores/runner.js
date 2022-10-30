// This store is for managing the running of tasks and storing their output.

import Reflux from 'reflux';

import * as taskIndex from '../../tasks';
const tasks = taskIndex.getTasksForPlatform('web');
import log from '../../log';

import RunnerActions from '../actions/runner';
import WindowActions from '../actions/window';

let RunnerStore = Reflux.createStore({
  listenables: [RunnerActions],

  init() {
    this.data = this.getInitialState();
    this.taskIsRunning = false;
  },

  getInitialState() {
    if (this.data) {
      return this.data;
    } else {
      return [];
    }
  },

  isRunningTask() {
    return this.taskIsRunning;
  },

  onRunTask(name, options) {
    RunnerActions.clearLog();
    WindowActions.navigate('/output');

    log.subscribe(RunnerActions.logMessage);
    this.taskIsRunning = true;

    let handleEnd = () => {
      log.unsubscribeAll();
      this.taskIsRunning = false;
    };

    tasks[name]
      .run(options)
      .then(() => {
        handleEnd();
      })
      .catch(() => {
        handleEnd();
      });
  },

  onLogMessage(level, content) {
    this.data.push({ level, content });
    this.trigger(this.data);
  },

  onClearLog() {
    this.data.length = 0;
    this.trigger(this.data);
  },
});

export default RunnerStore;
