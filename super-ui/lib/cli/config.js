import path from 'path';
import fs from 'fs';

import userHome from 'user-home';
let configLocation = path.join(userHome, 'le-serf-config.json');

import log from '../log';
import util from '../util';

import inquirer from 'inquirer';

const initialSetupQuestions = [
  {
    name: 'empire',
    message: "What is your empire's name?",
  },
  {
    name: 'password',
    type: 'password',
    message: "What is your empire's password?",
  },
  {
    name: 'server',
    message: 'What server is this empire on?',
    default: 'us1',
  },
  {
    name: 'apiKey',
    message: 'What API key do you want to use?',
    default: 'anonymous',
  },
];

let load = () => {
  let config = {};

  try {
    config = require(configLocation);
  } catch (e) {
    if (util.regexMatch(/cannot find module/i, e.message)) {
      log.error('Config file has not been created');
      log.info('Use `le-serf setup` to create a config');
      process.exit(1);
    } else {
      log.error(e.message);
    }
  }

  return config;
};

let save = (config, cb) => {
  fs.writeFile(configLocation, JSON.stringify(config), (err) => {
    if (err) {
      log.error(err);
    } else {
      cb();
    }
  });
};

let setup = (cb) => {
  inquirer.prompt(initialSetupQuestions, (answers) => {
    save(answers, cb);
  });
};

let clear = (cb) => {
  fs.unlink(configLocation, (err) => {
    if (err) {
      log.error(err);
    } else {
      cb();
    }
  });
};

export { clear, load, save, setup };
