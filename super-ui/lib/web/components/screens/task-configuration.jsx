import React from 'react';

import TaskConfigurationSection from '../menu/task-configuration-section';

let TasksScreen = React.createClass({
  render() {
    return (
      <div className='row'>
        <div className='col-md-4 col-md-offset-4'>
          <TaskConfigurationSection />
        </div>
      </div>
    );
  },
});

export default TasksScreen;
