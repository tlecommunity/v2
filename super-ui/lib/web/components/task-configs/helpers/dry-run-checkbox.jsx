import React from 'react';

import Checkbox from './checkbox';

let DryRunCheckbox = React.createClass({
  propTypes: {
    children: React.PropTypes.oneOfType([
      React.PropTypes.element,
      React.PropTypes.node,
      React.PropTypes.undefined,
    ]),
  },

  isChecked() {
    return this.refs.checkbox.isChecked();
  },

  render() {
    return (
      <div>
        <Checkbox
          label='Dry Run'
          description='Runs the task and shows what would happen without actually changing anything'
          ref='checkbox'
        >
          {this.props.children}
        </Checkbox>
      </div>
    );
  },
});

export default DryRunCheckbox;
