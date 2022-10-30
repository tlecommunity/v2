import Building from '../building';

class StationCommand extends Building {
  constructor() {
    super('stationcommand');

    this.apiMethods('stationcommand', ['view', 'view_plans', 'view_incoming_supply_chains']);
  }
}

export default StationCommand;
