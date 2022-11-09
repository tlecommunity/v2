<template>
  <div class="form">
    <div class="form-group">
      <ColonyList name="planet" label="Planet" all />
    </div>

    <div class="form-group">
      <ShipList name="type" label="Ship" />
    </div>

    <div class="form-group">
      <label htmlFor="quantityField">Quantity</label>
      <input
        type="number"
        class="form-control"
        name="quantity"
        placeholder="How many ships do you want to build?"
      />
    </div>

    <Checkbox
      label="Top Off"
      description="Top off existing ships to the specified quantity"
      name="topoff"
    />

    <DryRunCheckbox name="dryRun" />
  </div>
</template>

<script>
import ColonyList from './helpers/colony-list.vue';
import ShipList from './helpers/ship-list.vue';
import Checkbox from './helpers/checkbox.vue';
import DryRunCheckbox from './helpers/dry-run-checkbox.vue';

export default {
  components: { ColonyList, Checkbox, DryRunCheckbox, ShipList },
};
</script>
