import Module from './module';

class Building extends Module {
  constructor(url) {
    super();

    this.apiMethods(url, [
      'build',
      'demolish',
      'downgrade',
      'get_stats_for_level',
      'repair',
      'upgrade',
      'view',
    ]);
  }
}

export default Building;
