<template>
  <div class="row">
    <div class="col-md-4 col-md-offset-4">
      <form @submit.prevent="runTask">
        <div class="text-center">
          <h1>{{ taskTitle }}</h1>
          <p>{{ taskDescription }}</p>
        </div>

        <component :is="taskName" />

        <div class="text-center">
          <input type="submit" class="btn btn-success btn-lg" style="width: 50%" value="Run" />
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import { getTaskByName } from '../../../tasks';

import BuildShips from '../task-configs/build-ships.vue';
import DockedShips from '../task-configs/docked-ships.vue';
import HallsCost from '../task-configs/halls-cost.vue';
import MakeHalls from '../task-configs/make-halls.vue';
import PushBuildingsUp from '../task-configs/push-buildings-up.vue';
import PushGlyphs from '../task-configs/push-glyphs.vue';
import ScuttleShips from '../task-configs/scuttle-ships.vue';
import SpySkills from '../task-configs/spy-skills.vue';
import SpyStatus from '../task-configs/spy-status.vue';
import SpyTrainer from '../task-configs/spy-trainer.vue';
import ViewLaws from '../task-configs/view-laws.vue';

import * as App from '../../app';

export default {
  methods: {
    runTask(event) {
      App.navigate(`/task-runner/${this.taskName}/${$(event.target).serialize()}`);
    },
  },

  computed: {
    task() {
      return getTaskByName(this.$route.params.task);
    },

    taskName() {
      return this.task?.name || '';
    },

    taskTitle() {
      return this.task?.title || '';
    },

    taskDescription() {
      return this.task?.description || '';
    },
  },

  components: {
    'build-ships': BuildShips,
    'docked-ships': DockedShips,
    'halls-cost': HallsCost,
    'make-halls': MakeHalls,
    'push-buildings-up': PushBuildingsUp,
    'push-glyphs': PushGlyphs,
    'scuttle-ships': ScuttleShips,
    'spy-skills': SpySkills,
    'spy-status': SpyStatus,
    'spy-trainer': SpyTrainer,
    'view-laws': ViewLaws,
  },
};
</script>
