import { reactive } from '@vue/reactivity';
import store from 'store';

class SessionStore {
  data = reactive({
    sessionId: store.get('session') || '',
  });

  set(session) {
    this.sessionId = session;
    store.set('session', this.sessionId);
  }

  get() {
    return this.sessionId;
  }

  clear() {
    this.sessionId = '';
    store.set('session', this.data);
  }
}

export default new SessionStore();
