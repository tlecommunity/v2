import _ from 'lodash';
import camelize from 'camelize';

import emissary from './emissary';

class Module {
  apiMethods(moduleId, methods) {
    methods.forEach((method) => {
      this[camelize(method)] = _.partial(emissary.serverCall, moduleId, method);
    });
  }
}

export default Module;
