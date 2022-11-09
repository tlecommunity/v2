<template>
  <div class="form">
    <div class="form-group">
      <ColonyList name="planet" label="Select Planet" all />
    </div>

    <Checkbox name="loop" label="Loop" description="Wait for buildings to upgrade and go agin" />

    <DryRunCheckbox name="dryRun" />
  </div>
</template>

<script>
import ColonyList from './helpers/colony-list.vue';
import Checkbox from './helpers/checkbox.vue';
import DryRunCheckbox from './helpers/dry-run-checkbox.vue';

export default {
  components: { ColonyList, Checkbox, DryRunCheckbox },
};
</script>
