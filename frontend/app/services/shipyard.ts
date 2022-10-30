import ServiceBase from 'app/services/base';
import {
  ShipyardViewBuildQueueParams,
  ShipyardGetBuildableParams,
  ShipyardBuildFleetParams,
  ShipyardSubsidizeBuildQueueParams,
} from 'app/interfaces/shipyard';

class SpacePortService extends ServiceBase {
  viewBuildQueue(params: ShipyardViewBuildQueueParams) {
    return this.call('shipyard', 'view_build_queue', params);
  }

  getBuildable(params: ShipyardGetBuildableParams) {
    return this.call('shipyard', 'get_buildable', params);
  }

  buildFleet(params: ShipyardBuildFleetParams) {
    return this.call('shipyard', 'build_fleet', params);
  }

  subsidizeBuildQueue(params: ShipyardSubsidizeBuildQueueParams) {
    return this.call('shipyard', 'subsidize_build_queue', params);
  }
}

export default new SpacePortService();
