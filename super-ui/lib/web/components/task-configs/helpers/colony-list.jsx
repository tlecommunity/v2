import React from 'react';
import Reflux from 'reflux';

import BodyList from './body-list';

import EmpireStore from '../../../stores/empire';

let ColonyList = React.createClass({
  mixins: [Reflux.connect(EmpireStore, 'empire')],

  propTypes: {
    all: React.PropTypes.bool,
    label: React.PropTypes.string,
  },

  getDefaultProps() {
    return {
      all: true,
      label: 'Colony',
    };
  },

  getSelected() {
    return this.refs.list.getSelected();
  },

  render() {
    return (
      <BodyList
        bodies={this.state.empire.colonies}
        all={this.props.all}
        label={this.props.label}
        ref='list'
      />
    );
  },
});

export default ColonyList;
