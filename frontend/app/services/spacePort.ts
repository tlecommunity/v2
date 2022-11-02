import ServiceBase from 'app/services/base';
import {
  SpacePortViewAllFleetsParams,
  SpacePortViewTravellingFleetsParams,
  SpacePortViewAvailableFleetsParams,
  SpacePortViewUnavailableFleetsParams,
  SpacePortViewOrbitingFleetsParams,
  SpacePortViewIncomingFleetsParams,
  SpacePortSendFleetParams,
} from 'app/interfaces';

class SpacePortService extends ServiceBase {
  viewAllFleets(params: SpacePortViewAllFleetsParams) {
    return this.call('spaceport', 'view_all_fleets', params);
  }

  viewTravellingFleets(params: SpacePortViewTravellingFleetsParams) {
    return this.call('spaceport', 'view_travelling_fleets', params);
  }

  viewAvailableFleets(params: SpacePortViewAvailableFleetsParams) {
    return this.call('spaceport', 'view_available_fleets', params);
  }

  viewUnavailableFleets(params: SpacePortViewUnavailableFleetsParams) {
    return this.call('spaceport', 'view_unavailable_fleets', params);
  }

  viewOrbitingFleets(params: SpacePortViewOrbitingFleetsParams) {
    return this.call('spaceport', 'view_orbiting_fleets', params);
  }

  viewIncomingFleets(params: SpacePortViewIncomingFleetsParams) {
    return this.call('spaceport', 'view_incoming_fleets', params);
  }

  sendFleet(params: SpacePortSendFleetParams) {
    return this.call('spaceport', 'send_fleet', params);
  }
}

export default new SpacePortService();
