<template>
  <div class="row">
    <div class="col-md-10 col-md-offset-1">
      <h1 class="text-center">Output</h1>
      <div
        :style="{
          backgroundColor: '#434e56',
          borderRadius: 5,
          color: '#f1f1f1',
          marginBottom: 20,
          padding: 20,
          width: '100%',
          minHeight: 50,
          overflow: 'auto',
          fontFamily: 'monospace',
          whiteSpace: 'pre',
          lineHeight: 0.5,
        }"
      >
        <LogMessage v-for="log in logs" :level="log.level" :content="log.message" />
      </div>
    </div>
  </div>
</template>

<script>
import * as App from '../../app';
import _ from 'lodash';
import log from '../../../log';
import { getTaskByName } from '../../../tasks';
import LogMessage from '../menu/log-message.vue';

export default {
  data() {
    return {
      logs: [],
    };
  },

  mounted() {
    console.log('task', this.$route.params.task);
    console.log('config', this.$route.params.config);

    const task = getTaskByName(this.$route.params.task);

    if (!task) {
      App.error('Task not found');
      App.navigate('/task-selection');
      return;
    }

    const urlParams = new URLSearchParams(this.$route.params.config);
    const config = Object.fromEntries(urlParams.entries());

    if (!_.includes(task.platforms, 'web')) {
      App.error('Cannot run this task on the web');
      App.navigate('/task-selection');
      return;
    }

    console.log(`Running ${task.name} with config`, config);

    log.subscribe((level, message) => {
      this.logs.push({ level, message });
    });

    const handleEnd = () => {
      log.unsubscribeAll();
    };

    task
      .run(config)
      .then(() => {
        handleEnd();
      })
      .catch((e) => {
        console.error(e);
        handleEnd();
      });
  },

  components: { LogMessage },
};
</script>
