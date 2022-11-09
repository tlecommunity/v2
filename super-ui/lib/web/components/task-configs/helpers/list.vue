<template>
  <div>
    <label>{{ label }}</label>
    <select class="form-control" :name="name">
      <option v-for="item in list" :value="item.value">{{ item.name }}</option>
    </select>
  </div>
</template>

<script>
export default {
  props: ['label', 'name', 'list'],
};
</script>
