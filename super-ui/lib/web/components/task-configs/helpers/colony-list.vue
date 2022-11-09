<template>
  <List :label="label" :name="name" :list="bodies" />
</template>

<script>
import _ from 'lodash';
import List from './list.vue';
import EmpireStore from '../../../stores/empire';

export default {
  props: {
    label: String,
    name: String,
    all: Boolean,
  },

  components: { List },

  computed: {
    bodies() {
      const bodies = [];

      if (this.all) {
        bodies.push({ name: 'All', value: 'all' });
      }

      if (EmpireStore?.data?.bodies?.colonies) {
        _.each(EmpireStore.data.bodies.colonies, ({ name }) => {
          bodies.push({ name, value: name });
        });
      }

      return bodies;
    },
  },
};
</script>
