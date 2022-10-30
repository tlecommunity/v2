import React from 'react';
import Reflux from 'reflux';

import { Link } from 'react-router';

import WindowActions from '../../actions/window';
import EmpireActions from '../../actions/empire';

import EmpireStore from '../../stores/empire';

let BrandSection = React.createClass({
  handleClick(e) {
    e.preventDefault();

    if (EmpireStore.getData().name) {
      WindowActions.navigate('/task-selection');
    } else {
      WindowActions.navigate('/login');
    }
  },

  render() {
    return (
      <div className='navbar-header'>
        <a className='navbar-brand' href='#' onClick={this.handleClick}>
          Le Serf
        </a>
      </div>
    );
  },
});

let LinksSection = React.createClass({
  render() {
    return (
      <ul className='nav navbar-nav navbar-left'>
        <li>
          <Link to='/task-selection'>Tasks</Link>
        </li>
        <li>
          <Link to='/output'>Output</Link>
        </li>
        <li>
          <a target='_blank' href='http://1vasari.github.io/le-serf-docs/'>
            Documentation
          </a>
        </li>
        <li>
          <Link to='/about'>About</Link>
        </li>
      </ul>
    );
  },
});

let EmpireSection = React.createClass({
  mixins: [Reflux.connect(EmpireStore, 'empire')],

  logout() {
    EmpireActions.logout();
  },

  render() {
    return (
      <p className='navbar-text navbar-right' style={{ marginRight: 15 }}>
        {this.state.empire.name ? (
          <span>
            Logged in as {this.state.empire.name} |{' '}
            <span>
              <a
                onClick={this.logout}
                style={{
                  cursor: 'pointer',
                }}
              >
                Log out
              </a>
            </span>
          </span>
        ) : (
          <span>
            Not logged in | <Link to='/login'>Login</Link>
          </span>
        )}
      </p>
    );
  },
});

let NavBar = React.createClass({
  render() {
    return (
      <div className='navbar navbar-default'>
        <BrandSection />
        <LinksSection />
        <EmpireSection />
      </div>
    );
  },
});

export default NavBar;
