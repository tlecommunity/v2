import _ from 'lodash';

import cache from './cache';
import log from '../log';
import util from '../util';
import lacuna from '../lacuna';

let emissary = {
  getUrl(moduleId) {
    const server = cache.get('config').server;

    if (server.startsWith('http')) {
      return `${server}/${moduleId}`;
    } else {
      let protocol = window !== 'undefined' ? window.location.protocol : 'http:';
      return `${protocol}//${server}.lacunaexpanse.com/${moduleId}`;
    }
  },

  addSession(moduleId, method, params) {
    // Add session ID to the params.
    let sessionId = cache.get('session');
    if (`${moduleId}/${method}` !== 'empire/login') {
      if (_.isArray(params)) {
        params = [sessionId].concat(params);
      } else if (_.isObject(params)) {
        params.session_id = sessionId;
      }
    }

    return params;
  },

  getJsonRequest(method, params) {
    return {
      jsonrpc: '2.0',
      id: 1,
      method,
      params,
    };
  },

  getReqOptions(moduleId, method, params) {
    return {
      url: emissary.getUrl(moduleId),
      json: emissary.getJsonRequest(method, emissary.addSession(moduleId, method, params)),
      method: 'POST',
    };
  },

  async serverCall(moduleId, method, params = []) {
    const url = emissary.getUrl(moduleId);
    const data = emissary.getJsonRequest(method, emissary.addSession(moduleId, method, params));

    log.debug(`Sending to ${url} with:`, data);

    const res = await window.fetch(url, {
      method: 'POST',
      mode: 'cors',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });

    const json = await res.json();

    // NOTE: handle this error before `err` to avoid an unfriendly error message being emitted.
    if (!json) {
      reject('Connection to the server has been lost');
      return;
    }

    log.silly('Received:', json);

    if (json.result) {
      return json.result;
    } else if (json.error) {
      if (util.regexMatch(/^Slow down/, json.error.message)) {
        log.newline();
        log.warn('Hit the click limit - waiting for a minute');

        await new Promise((resolve) => {
          setTimeout(() => {
            log.info('Trying again');
            log.newline();
            resolve();
          }, 61 * 1000);
        });

        return emissary.serverCall(moduleId, method, params);
      } else if (json.error.message === 'Session expired.') {
        log.newline();
        log.warn('Session expired - logging in again');

        return lacuna.newSession().then(() => {
          log.info('Trying again');
          log.newline();

          return emissary.serverCall(moduleId, method, params);
        });
      } else {
        throw json.error.message;
      }
    } else if (body === 'Not Found') {
      throw `${reqOptions.url} not found`;
    } else {
      throw body;
    }
  },
};

export default emissary;
