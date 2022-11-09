<template>
  <div>
    <div class="container-fluid">
      <NavBar />
      <div><router-view></router-view></div>
    </div>
  </div>
</template>

<script>
import * as bootstrapper from '../bootstrapper';
import NavBar from './menu/nav-bar.vue';

export default {
  mounted() {
    bootstrapper.handleInitialLogin();
  },

  components: {
    NavBar,
  },
};
</script>
