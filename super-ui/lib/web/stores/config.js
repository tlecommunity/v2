// This store is for the information for logging into the game.
// If you want to display the "current empire" DO NOT use listen to this store!
// Instead, listen to the empire store.

import Reflux from 'reflux';
import store from 'store';

import ConfigActions from '../actions/config';

let ConfigStore = Reflux.createStore({
  listenables: [ConfigActions],

  init() {
    this.data = this.getInitialState();
  },

  getInitialState() {
    if (this.data) {
      return this.data;
    } else {
      let storedConfig = store.get('empire');
      return storedConfig || {};
    }
  },

  getData() {
    return this.data;
  },

  onSet(data) {
    this.data = data;
    store.set('empire', this.data);
    this.trigger(this.data);
  },

  onClear() {
    this.data = {};
    store.set('empire', this.data);
    this.trigger(this.data);
  },
});

export default ConfigStore;
