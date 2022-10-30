import React from 'react';

import ColonyList from './helpers/colony-list';

let SpySkillsConfig = React.createClass({
  getOptions() {
    return {
      planet: this.refs.colonyList.getSelected().name,
    };
  },

  render() {
    return (
      <div className='form'>
        <div className='form-group'>
          <ColonyList ref='colonyList' />
        </div>
      </div>
    );
  },
});

export default SpySkillsConfig;
