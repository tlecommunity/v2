<template>
  <div>
    <div class="form-group">
      <div class="checkbox">
        <label> <input type="checkbox" v-model="checked" :name="name" /> {{ label }}</label>
        <span class="help-block">{{ description }}</span>
      </div>
    </div>

    <div class="form-group" v-if="!checked">
      <slot></slot>
    </div>
  </div>
</template>

<script>
export default {
  props: ['label', 'description', 'name'],

  data() {
    return {
      checked: false,
    };
  },
};
</script>
