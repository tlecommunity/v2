import React from 'react';
import ReactDOM from 'react-dom';

import { Router, Route } from 'react-router';

import AboutScreen from './components/screens/about';
import LoginScreen from './components/screens/login';
import OutputScreen from './components/screens/output';
import TaskConfigurationScreen from './components/screens/task-configuration';
import TaskSelectionScreen from './components/screens/task-selection';

import App from './components/app';

import history from './history';

import './error-handler';

// This function is called by the loader after it's finished doing its thing.
window.LeSerfLoad = () => {
  let container = document.getElementById('main');
  let app = (
    <Router history={history}>
      <Route path='/' component={App}>
        <Route path='about' component={AboutScreen} />
        <Route path='login' component={LoginScreen} />
        <Route path='output' component={OutputScreen} />
        <Route path='task-configuration' component={TaskConfigurationScreen} />
        <Route path='task-selection' component={TaskSelectionScreen} />
      </Route>
    </Router>
  );

  if (container) {
    ReactDOM.render(app, container);
  }
};
