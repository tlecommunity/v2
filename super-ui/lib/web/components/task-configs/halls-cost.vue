<template>
  <div class="form">
    <div class="form-group">
      <label>Start</label>
      <select class="form-control" name="start" v-model="start">
        <option v-for="level in levels" :value="level">{{ level }}</option>
      </select>
    </div>

    <div class="form-group">
      <label>End</label>
      <select class="form-control" name="end" v-model="end">
        <option v-for="level in levels" :value="level">{{ level }}</option>
      </select>
    </div>
  </div>
</template>

<script>
import _ from 'lodash';

export default {
  data() {
    return {
      levels: _.range(1, 31),
      start: 1,
      end: 30,
    };
  },
};
</script>
