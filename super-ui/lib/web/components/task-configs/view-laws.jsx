import React from 'react';

import util from '../../../util';

let ViewLawsConfig = React.createClass({
  getOptions() {
    return {
      id: util.int(this.refs.idField.value),
    };
  },

  render() {
    return (
      <div className='form'>
        <div className='form-group'>
          <label htmlFor='idField'>Space Station ID</label>
          <input
            type='email'
            className='form-control'
            id='idField'
            ref='idField'
            placeholder='123456'
          ></input>
        </div>
      </div>
    );
  },
});

export default ViewLawsConfig;
