<template>
  <div class="row">
    <div class="col-md-4 col-md-offset-4">
      <h1 class="center-text">Select a Task</h1>

      <ul>
        <li v-for="task in tasks" style="cursor: pointer">
          <router-link :to="'/task-configuration/' + task.name" :title="task.description">{{
            task.title
          }}</router-link>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import * as taskIndex from '../../../../lib/tasks';

export default {
  data() {
    return {
      tasks: taskIndex.getTasksForPlatform('web'),
    };
  },
};
</script>
