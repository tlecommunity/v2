<template>
  <div class="navbar navbar-default">
    <div class="navbar-header">
      <router-link :to="this.isAuthenticated ? '/task-selection' : '/login'" class="navbar-brand">
        TLE Power UI
      </router-link>
    </div>

    <ul class="nav navbar-nav navbar-left">
      <li v-if="isAuthenticated">
        <router-link to="/task-selection">Tasks</router-link>
      </li>
      <li>
        <a target="_blank" href="https://1vasari.github.io/le-serf-docs/">Documentation</a>
      </li>
      <li>
        <router-link to="/about">About</router-link>
      </li>
    </ul>

    <p class="navbar-text navbar-right" style="margin-right: 15px">
      <span v-if="isAuthenticated">
        Logged in as {{ this.empire.name }} |
        <span>
          <a @click="logout" style="cursor: pointer">Log out</a>
        </span>
      </span>
      <span v-if="!isAuthenticated">
        Not logged in | <router-link to="/login">Login</router-link>
      </span>
    </p>
  </div>
</template>

<script>
import EmpireStore from '../../stores/empire';
import * as App from '../../app';

export default {
  data() {
    return {
      empire: EmpireStore.data,
    };
  },

  methods: {
    onBrandClick() {
      if (this.empire.name) {
        App.navigate('/task-selection');
      } else {
        App.navigate('/login');
      }
    },

    logout() {
      EmpireStore.logout();
    },
  },

  computed: {
    isAuthenticated() {
      return !!this.empire.name;
    },
  },
};
</script>
