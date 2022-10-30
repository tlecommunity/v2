import React from 'react';
import _ from 'lodash';

import ColonyList from './helpers/colony-list';
import List from './helpers/list';

import constants from '../../../constants';

let ScuttleShipsConfig = React.createClass({
  getOptions() {
    return {
      planet: this.refs.colonyList.getSelected().name,
      type: this.refs.shipList.getValue(),
    };
  },

  render() {
    let shipList = _.chain(constants.shipTypes)
      .mapValues((serverName, displayName) => {
        return {
          name: displayName,
          value: serverName,
        };
      })
      .sortBy('name')
      .thru((arr) => {
        return [
          {
            name: 'All Ships',
            value: 'all',
          },
        ].concat(arr);
      })
      .value();

    return (
      <div className='form'>
        <div className='form-group'>
          <ColonyList ref='colonyList' />
        </div>

        <div className='form-group'>
          <List list={shipList} label='Ship' ref='shipList' />
        </div>
      </div>
    );
  },
});

export default ScuttleShipsConfig;
