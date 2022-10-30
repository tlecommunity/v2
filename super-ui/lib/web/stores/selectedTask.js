import Reflux from 'reflux';

import RunnerActions from '../actions/runner';
import WindowActions from '../actions/window';

let SelectedTaskStore = Reflux.createStore({
  listenables: [RunnerActions],

  init() {
    this.data = this.getInitialState();
  },

  getInitialState() {
    return this.data || '';
  },

  onSetSelectedTask(newTask) {
    this.data = newTask;
    this.trigger(this.data);
    WindowActions.navigate('/task-configuration');
  },
});

export default SelectedTaskStore;
