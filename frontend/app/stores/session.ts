import { makeAutoObservable } from 'mobx';
import lacuna from 'app/lacuna';

class SessionStore {
  session = '';

  constructor() {
    makeAutoObservable(this);
  }

  update(session: string) {
    this.session = session;
    lacuna.session.set(session);
  }
}

export default new SessionStore();
