import React from 'react';

import ColonyList from './helpers/colony-list';

let MakeHallsConfig = React.createClass({
  getOptions() {
    return {
      planet: this.refs.list.getSelected().name,
    };
  },

  render() {
    return (
      <div className='form'>
        <div className='form-group'>
          <ColonyList ref='list' />
        </div>
      </div>
    );
  },
});

export default MakeHallsConfig;
