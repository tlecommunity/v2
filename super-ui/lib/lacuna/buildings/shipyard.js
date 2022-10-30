import Building from '../building';

class Shipyard extends Building {
  constructor() {
    super('shipyard');

    this.apiMethods('shipyard', [
      'build_ship',
      'build_ships',
      'get_buildable',
      'subsidize_build_queue',
      'subsidize_ship',
      'view_build_queue',
    ]);
  }
}

export default Shipyard;
