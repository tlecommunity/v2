import React from 'react';

import ColonyList from './helpers/colony-list';
import DryRunCheckbox from './helpers/dry-run-checkbox';
import Checkbox from './helpers/checkbox';

let PushBuildingsUpConfig = React.createClass({
  getOptions() {
    return {
      planet: this.refs.list.getSelected().name,
      dryRun: this.refs.dryRun.isChecked(),
      loop: this.refs.loop.isChecked(),
    };
  },

  render() {
    return (
      <div className='form'>
        <div className='form-group'>
          <ColonyList ref='list' />
        </div>

        <Checkbox ref='loop' label='Loop' description='Wait for buildings to upgrade and go agin' />

        <DryRunCheckbox ref='dryRun' />
      </div>
    );
  },
});

export default PushBuildingsUpConfig;
