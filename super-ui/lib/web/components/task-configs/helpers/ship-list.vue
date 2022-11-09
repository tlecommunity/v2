<template>
  <List :list="ships" :label="label" :name="name" />
</template>

<script>
import _ from 'lodash';
import constants from '../../../../constants';
import List from './list.vue';

export default {
  props: ['label', 'name'],

  data() {
    return {
      ships: _.chain(constants.shipTypes)
        .mapValues((serverName, displayName) => {
          return {
            name: displayName,
            value: serverName,
          };
        })
        .sortBy('name')
        .value(),
    };
  },

  components: { List },
};
</script>
