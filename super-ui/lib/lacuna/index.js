import _ from 'lodash';

import cache from './cache';
import log from '../log';

import Alliance from './modules/alliance';
import Body from './modules/body';
import Captcha from './modules/captcha';
import Empire from './modules/empire';
import Inbox from './modules/inbox';
import Map from './modules/map';
import Stats from './modules/stats';

import Building from './building';

import Archaeology from './buildings/archaeology';
import Intelligence from './buildings/intelligence';
import PlanetaryCommand from './buildings/planetaryCommand';
import Shipyard from './buildings/shipyard';
import SpacePort from './buildings/spaceport';
import Trade from './buildings/trade';

import Parliament from './ssbuildings/parliament';
import PoliceStation from './ssbuildings/policeStation';
import StationCommand from './ssbuildings/stationCommand';

const defaults = {
  apiKey: 'anonymous',
  empire: '',
  password: '',
  server: 'us1',
};

/**
 * This object is for interacting with the Lacuna game server.
 *
 * @namespace lacuna
 */
let lacuna = {
  init(config, session) {
    if (config) {
      // Handle defaults and stuff
      let obj = _.merge({}, defaults, config);
      cache.put('config', obj);
    } else {
      log.error('No config passed to lacuna.init()');
    }

    if (session) {
      cache.put('session', session);
    }

    return lacuna;
  },

  // Base Modules
  alliance: new Alliance(),
  body: new Body(),
  captcha: new Captcha(),
  empire: new Empire(),
  inbox: new Inbox(),
  map: new Map(),
  stats: new Stats(),

  buildings: {
    archaeology: new Archaeology(),
    generic: (url) => new Building(url.replace(/\//g, '')),
    intelligence: new Intelligence(),
    planetaryCommand: new PlanetaryCommand(),
    shipyard: new Shipyard(),
    spaceport: new SpacePort(),
    trade: new Trade(),
  },

  modules: {
    parliament: new Parliament(),
    policeStation: new PoliceStation(),
    stationCommand: new StationCommand(),
  },

  authenticate() {
    let config = cache.get('config');
    let session = cache.get('session');

    if (session) {
      return new Promise((resolve, reject) => resolve(session));
    } else {
      log.info(`Logging into empire ${config.empire}`);

      if (!config.empire || !config.password) {
        return new Promise((resolve, reject) => {
          reject('Empire name and password are required');
        });
      }

      return lacuna.empire
        .login({
          name: config.empire,
          password: config.password,
          api_key: config.apiKey,
          browser: 'todo',
        })
        .then((result) => {
          let session = result.session_id;
          log.info('Received session id: ' + session);
          cache.put('session', session);
          return session;
        });
    }
  },

  newSession() {
    cache.put('session', '');
    return lacuna.authenticate();
  },

  getConfig() {
    return cache.get('config');
  },

  getSession() {
    return cache.get('session');
  },
};

export default lacuna;
