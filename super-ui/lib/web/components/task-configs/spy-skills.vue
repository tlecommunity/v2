<template>
  <div class="form">
    <div class="form-group">
      <ColonyList name="planet" label="Planet" all />
    </div>
  </div>
</template>

<script>
import ColonyList from './helpers/colony-list.vue';

export default {
  components: { ColonyList },
};
</script>
