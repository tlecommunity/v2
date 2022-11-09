// This store is for storing the currently logged-in empire.
// If you want to display information about the currently logged-in empire,
// this is the store to listen in on!

import lacuna from '../../lacuna';
import ConfigStore from '../stores/config';
import SessionStore from '../stores/session';
import * as App from '../app';
import { reactive } from 'vue';

class EmpireStore {
  data = reactive({
    bodies: {
      colonies: [],
      stations: [],
    },
    colonies: {},
    essentia: 0,
    has_new_messages: 0,
    home_planet_id: 0,
    id: '',
    insurrect_value: 0,
    is_isolationist: 0,
    latest_message_id: 0,
    name: '',
    next_colony_cost: 0,
    next_colony_srcs: 0,
    next_station_cost: 0,
    planets: {},
    primary_embassy_id: 0,
    rpc_count: 0,
    self_destruct_active: 0,
    self_destruct_date: '',
    stations: {},
    status_message: '',
    tech_level: 0,
  });

  login() {
    lacuna
      .authenticate()
      .then(
        () => {
          ConfigStore.set(lacuna.getConfig());
          return lacuna.empire.getStatus({});
        },
        (message) => {
          App.error(message);
          App.navigate('/login');
        }
      )
      .then(({ status }) => {
        this.data.bodies = status.empire.bodies;
        this.data.colonies = status.empire.colonies;
        this.data.essentia = status.empire.essentia;
        this.data.has_new_messages = status.empire.has_new_messages;
        this.data.home_planet_id = status.empire.home_planet_id;
        this.data.id = status.empire.id;
        this.data.insurrect_value = status.empire.insurrect_value;
        this.data.is_isolationist = status.empire.is_isolationist;
        this.data.latest_message_id = status.empire.latest_message_id;
        this.data.name = status.empire.name;
        this.data.next_colony_cost = status.empire.next_colony_cost;
        this.data.next_colony_srcs = status.empire.next_colony_srcs;
        this.data.next_station_cost = status.empire.next_station_cost;
        this.data.planets = status.empire.planets;
        this.data.primary_embassy_id = status.empire.primary_embassy_id;
        this.data.rpc_count = status.empire.rpc_count;
        this.data.self_destruct_active = status.empire.self_destruct_date;
        this.data.self_destruct_date = status.empire.self_destruct_active;
        this.data.stations = status.empire.stations;
        this.data.status_message = status.empire.status_message;
        this.data.tech_level = status.empire.tech_level;

        // Whether logging in from a stored config, session ID or some new credentials, all pathways
        // lead back to here. So, we store the session now.
        SessionStore.set(lacuna.getSession());

        App.navigate('/task-selection');
      });
  }

  logout() {
    ConfigStore.clear();
    SessionStore.clear();
    this.clear();
    App.navigate('/login');
  }

  clear() {
    this.data.colonies = {};
    this.data.essentia = 0;
    this.data.has_new_messages = 0;
    this.data.home_planet_id = '';
    this.data.id = '';
    this.data.insurrect_value = 0;
    this.data.is_isolationist = 0;
    this.data.latest_message_id = 0;
    this.data.name = '';
    this.data.next_colony_cost = 0;
    this.data.next_colony_srcs = 0;
    this.data.next_station_cost = 0;
    this.data.planets = {};
    this.data.primary_embassy_id = 0;
    this.data.rpc_count = 0;
    this.data.self_destruct_active = 0;
    this.data.self_destruct_date = '';
    this.data.stations = {};
    this.data.status_message = '';
    this.data.tech_level = 0;
  }
}

export default new EmpireStore();
