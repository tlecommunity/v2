import React from 'react';

import * as bootstrapper from '../bootstrapper';

import NavBar from './menu/nav-bar';

let App = React.createClass({
  propTypes: {
    children: React.PropTypes.node,
  },

  componentDidMount() {
    bootstrapper.handleInitialLogin();
  },

  render() {
    return (
      <div>
        <div className='container-fluid'>
          <NavBar />

          <div>{this.props.children}</div>
        </div>
      </div>
    );
  },
});

export default App;
