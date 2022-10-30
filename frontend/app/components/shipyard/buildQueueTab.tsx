import React from 'react';
import BuildQueueItem from 'app/components/shipyard/buildQueue/item';
import { Building } from 'app/interfaces/building';
import { ShipyardViewBuildQueueResponse } from 'app/interfaces/shipyard';
import Shipyard from 'app/services/shipyard';

type Props = {
  building: Building;
};

type State = {
  data: ShipyardViewBuildQueueResponse;
};

class BuildQueueTab extends React.Component<Props, State> {
  constructor(props: any) {
    super(props);
    this.state = {
      data: {
        number_of_fleets: 0,
        cost_to_subsidize: 0,
        fleets_building: [],
      },
    };
  }

  async componentDidMount() {
    const data = await Shipyard.viewBuildQueue({ building_id: this.props.building.id });
    this.setState({
      data: {
        number_of_fleets: data.number_of_fleets,
        cost_to_subsidize: data.cost_to_subsidize,
        fleets_building: data.fleets_building,
      },
    });
  }

  async onSubsidizeClick() {
    const res = await Shipyard.subsidizeBuildQueue({ building_id: this.props.building.id });
    this.setState({
      data: {
        number_of_fleets: res.number_of_fleets,
        cost_to_subsidize: res.cost_to_subsidize,
        fleets_building: res.fleets_building,
      },
    });
  }

  render() {
    const fleetsBuilding = this.state.data.fleets_building;

    const buildQueueLen = fleetsBuilding.length;
    const fleetItems = [];

    for (let i = 0; i < buildQueueLen; i++) {
      fleetItems.push(
        <BuildQueueItem
          obj={fleetsBuilding[i]}
          building={this.props.building}
          key={fleetsBuilding[i].id}
        />
      );
    }

    return (
      <div>
        {fleetItems.length > 0 ? (
          <div>
            You may subsidize the whole build queue for {this.state.data.cost_to_subsidize}{' '}
            Essentia.{' '}
            <button
              type='button'
              className='ui mini green button'
              onClick={() => this.onSubsidizeClick()}
            >
              Subsidize
            </button>
          </div>
        ) : (
          ''
        )}

        <div className='ui sixteen column grid'>
          <div className='row'>
            <div className='column three wide'>Ship Type</div>
            <div className='column four wide'>Number of ships</div>
            <div className='column four wide'>Time to complete</div>
            <div className='column five wide'>Subsidize cost</div>
          </div>
        </div>

        <div className='ui divider' />

        <div>{fleetItems}</div>
      </div>
    );
  }
}

export default BuildQueueTab;
