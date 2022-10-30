import Module from '../module';

class Alliance extends Module {
  constructor() {
    super();

    this.apiMethods('alliance', ['find', 'view_profile']);
  }
}

export default Alliance;
