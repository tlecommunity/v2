<template>
  <div class="form">
    <div class="form-group">
      <ColonyList name="planet" label="Planet" all />
    </div>

    <div class="form-group">
      <DryRunCheckbox name="dryRun" />
    </div>
  </div>
</template>

<script>
import ColonyList from './helpers/colony-list.vue';
import DryRunCheckbox from './helpers/dry-run-checkbox.vue';

export default {
  components: { ColonyList, DryRunCheckbox },
};
</script>
