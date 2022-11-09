<template>
  <div class="form">
    <div class="form-group">
      <ColonyList name="planet" label="Planet" all />
    </div>

    <div class="form-group">
      <ShipList name="type" label="Ship" />
    </div>
  </div>
</template>

<script>
import ColonyList from './helpers/colony-list.vue';
import ShipList from './helpers/ship-list.vue';

export default {
  components: { ColonyList, ShipList },
};
</script>
