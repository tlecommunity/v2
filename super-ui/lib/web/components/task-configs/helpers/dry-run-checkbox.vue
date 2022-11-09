<template>
  <div>
    <Checkbox
      label="Dry Run"
      description="Runs the task and shows what would happen without actually changing anything"
      :name="name"
    >
      <slot></slot>
    </Checkbox>
  </div>
</template>

<script>
import Checkbox from './checkbox.vue';
export default {
  props: ['name'],
  components: { Checkbox },
};
</script>
