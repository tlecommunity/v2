import Reflux from 'reflux';
import store from 'store';

import SessionActions from '../actions/session';

let SessionStore = Reflux.createStore({
  listenables: [SessionActions],

  init() {
    this.data = this.getInitialState();
  },

  getInitialState() {
    if (this.data) {
      return this.data;
    } else {
      let storedSession = store.get('session');
      return storedSession || '';
    }
  },

  getData() {
    return this.data;
  },

  onSet(data) {
    this.data = data;
    store.set('session', this.data);
    this.trigger(this.data);
  },

  onClear() {
    this.data = '';
    store.set('session', this.data);
    this.trigger(this.data);
  },
});

export default SessionStore;
