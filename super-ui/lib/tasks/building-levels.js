import _ from 'lodash';
import Table from 'cli-table3';

import lacuna from '../lacuna';
import log from '../log';
import util from '../util';

class BuildingLevels {
  constructor(options) {
    this.options = options;
  }

  validateOptions() {
    return new Promise((resolve, reject) => {
      resolve(true);
    });
  }

  run() {
    return lacuna
      .authenticate()
      .then(() => {
        return lacuna.empire.getAllBuildings();
      })
      .then((buildings) => {
        let table = new Table({
          head: ['Level', 'Number of Buildings'],
        });

        _.each(_.range(0, 32), (level) => {
          let num = _.filter(buildings, (b) => {
            return util.int(b.level) === level;
          }).length;

          table.push([level, num]);
        });

        log.newline();
        log.info(table.toString());
        log.newline();

        let total = buildings.length;
        let mean = util.mean(_.map(buildings, 'level'));

        log.info(`Average building level is ${mean}`);
        log.info(`There are ${total} buildings`);
      });
  }
}

export default BuildingLevels;
