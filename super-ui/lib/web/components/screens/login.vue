<template>
  <div class="row">
    <div class="col-md-4 col-md-offset-4">
      <div class="form">
        <div class="form-group">
          <h2>Sign In</h2>
        </div>

        <div class="form-group">
          <label>Empire Name</label>
          <input type="text" class="form-control" placeholder="Empire Name" v-model="empire" />
        </div>

        <div class="form-group">
          <label>Password</label>
          <input type="password" class="form-control" v-model="password" placeholder="Password" />
        </div>

        <div class="form-group">
          <label>Server</label>
          <select class="form-control" v-model="server">
            <option value="https://us1.lacunaexpanse.com/">US1</option>
            <option value="https://pt.lacunaexpanse.com/">Public Test</option>
            <option value="http://localhost:8080">Local Server</option>
          </select>
        </div>

        <div class="form-group">
          <button class="btn btn-lg btn-primary btn-block" @click="handleLogin">Sign in</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import _ from 'lodash';
import * as bootstrapper from '../../bootstrapper';
import ConfigStore from '../../stores/config';

export default {
  data() {
    return {
      empire: ConfigStore.get().empire,
      password: ConfigStore.get().password,
      server: ConfigStore.get().server,
    };
  },

  methods: {
    handleLogin() {
      console.log(`Logging into ${this.server} with ${this.empire}`);
      bootstrapper.freshLogin({
        empire: this.empire,
        password: this.password,
        server: this.server,
      });
    },
  },
};
</script>
