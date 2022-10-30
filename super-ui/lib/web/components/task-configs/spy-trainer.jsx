import React from 'react';

import Captcha from './helpers/captcha';
import ColonyList from './helpers/colony-list';
import DryRunCheckbox from './helpers/dry-run-checkbox';

let SpyTrainerConfig = React.createClass({
  getOptions() {
    return {
      planet: this.refs.list.getSelected().name,
      dryRun: this.refs.dryRun.isChecked(),
    };
  },

  render() {
    return (
      <div className='form'>
        <div className='form-group'>
          <ColonyList ref='list' />
        </div>

        <DryRunCheckbox ref='dryRun'>
          <Captcha />
        </DryRunCheckbox>
      </div>
    );
  },
});

export default SpyTrainerConfig;
