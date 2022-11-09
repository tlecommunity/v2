// This store is for the information for logging into the game.
// If you want to display the "current empire" DO NOT use listen to this store!
// Instead, listen to the empire store.

import store from 'store';

class ConfigStore {
  config = store.get('empire') || {};

  get() {
    return this.config;
  }

  set(config) {
    this.config = config;
    store.set('empire', this.config);
  }

  clear() {
    this.config = {};
    store.set('empire', this.config);
  }
}

export default new ConfigStore();
