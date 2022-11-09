<template>
  <div class="text-center">
    <h1>About</h1>

    <p>
      Super UI version <a :href="changesLink" target="_blank">{{ version }}</a
      >.
    </p>

    <p>
      <img
        src="http://www.gravatar.com/avatar/730d1191aeca3e73b3693a52bf142929?s=200"
        class="img-circle"
      />
    </p>

    <p>
      The Super UI is an <a target="_blank" :href="repoURL">open source</a> creation by
      <a target="_blank" href="http://1vasari.xyz">1vasari</a>.
    </p>
  </div>
</template>

<script>
import { repository, version } from '../../../../package.json';
const repoURL = repository.url;

export default {
  data() {
    return {
      changesLink: repoURL + '#' + version.replace(/\./g, ''),
      version,
      repoURL,
    };
  },
};
</script>
