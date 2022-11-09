import _ from 'lodash';
import { createApp } from 'vue';
import { createRouter, createWebHashHistory } from 'vue-router';

import log from '../log';

import Viewport from './components/viewport.vue';
import HomeScreen from './components/screens/home.vue';
import AboutScreen from './components/screens/about.vue';
import LoginScreen from './components/screens/login.vue';
import TaskRunner from './components/screens/task-runner.vue';
import TaskConfigurationScreen from './components/screens/task-configuration.vue';
import TaskSelectionScreen from './components/screens/task-selection.vue';

const routes = [
  { path: '/', component: HomeScreen },
  { path: '/about', component: AboutScreen },
  { path: '/login', component: LoginScreen },
  { path: '/task-selection', component: TaskSelectionScreen },
  { path: '/task-configuration/:task', component: TaskConfigurationScreen },
  { path: '/task-runner/:task/:config', component: TaskRunner },
  { path: '/task-runner/:task', component: TaskRunner },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes,
});

const app = createApp(Viewport);
app.use(router);

let Messenger = () => {
  let M = window.Messenger;

  return M({
    theme: 'block',
    extraClasses: 'messenger-fixed messenger-on-top',
    maxMessages: 1,
  });
};

const messageDefaults = {
  showCloseButton: true,
  hideAfter: 10,
};

let handleDefaults = (options) => {
  return _.merge({}, messageDefaults, options);
};

const error = (message) => {
  log.error(message);

  window.alert(message);

  // Messenger().post(handleDefaults({
  //   message,
  //   type: 'error'
  // }))
};

const navigate = (path) => {
  router.push(path);
};

export { app, error, navigate };
