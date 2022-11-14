import _ from 'lodash';
import Table from 'cli-table3';
import Promise from 'bluebird';

import lacuna from '../lacuna';
import log from '../log';

class ViewLaws {
  constructor(options) {
    this.options = options;
  }

  validateOptions() {
    return new Promise((resolve, reject) => {
      if (!this.options.id) {
        reject('please specify a station');
      } else {
        resolve(true);
      }
    });
  }

  run() {
    return new Promise((resolve, reject) => {
      lacuna.body
        .viewLaws([this.options.id])
        .then((result) => {
          if (result.laws.length > 0) {
            let table = new Table({
              head: ['Name', 'Description'],
              colWidths: [30, 60],
            });

            _.each(result.laws, (law) => {
              table.push([law.name, law.description]);
            });

            log.newline();
            log.info(table.toString());
            log.newline();

            resolve(`Total of ${result.laws.length} laws enacted.`);
          } else {
            resolve(`No laws`);
          }
        })
        .catch(reject);
    });
  }
}

export default ViewLaws;
