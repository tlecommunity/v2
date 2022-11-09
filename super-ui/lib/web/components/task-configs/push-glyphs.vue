<template>
  <div class="form">
    <div class="form-group">
      <ColonyList name="from" label="From" all />
    </div>

    <div class="form-group">
      <ColonyList name="to" label="To" />
    </div>
  </div>
</template>

<script>
import ColonyList from './helpers/colony-list.vue';

export default {
  components: { ColonyList },
};
</script>
