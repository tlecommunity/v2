import React from 'react';
import _ from 'lodash';

import util from '../../../util';
import constants from '../../../constants';

import Checkbox from './helpers/checkbox';
import ColonyList from './helpers/colony-list';
import DryRunCheckbox from './helpers/dry-run-checkbox';
import List from './helpers/list';

let BuildShipsConfig = React.createClass({
  getOptions() {
    return {
      planet: this.refs.colonyList.getSelected().name,
      type: this.refs.shipList.getValue(),
      quantity: util.int(this.refs.quantityField.value),
      topoff: this.refs.topoff.isChecked(),
      dryRun: this.refs.dryRun.isChecked(),
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
      .value();

    return (
      <div className='form'>
        <div className='form-group'>
          <ColonyList ref='colonyList' />
        </div>

        <div className='form-group'>
          <List list={shipList} label='Ship' ref='shipList' />
        </div>

        <div className='form-group'>
          <label htmlFor='quantityField'>Quantity</label>
          <input
            type='text'
            className='form-control'
            id='quantityField'
            ref='quantityField'
            placeholder='How many ships do you want to build?'
          ></input>
        </div>

        <Checkbox
          label='Top Off'
          description='Top off existing ships to the specified quantity'
          ref='topoff'
        />

        <DryRunCheckbox ref='dryRun' />
      </div>
    );
  },
});

export default BuildShipsConfig;
