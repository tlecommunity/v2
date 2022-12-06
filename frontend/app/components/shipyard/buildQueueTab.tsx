import React from 'react';
import _ from 'lodash';
import BuildQueueItem from 'app/components/shipyard/buildQueue/item';
import { Building } from 'app/interfaces/building';
import { types } from '@tlecommunity/client';
import lacuna from 'app/lacuna';

type Props = {
  building: Building;
};

type State = {
  data: types.Shipyard.ViewBuildQueueResponse;
};

class BuildQueueTab extends React.Component<Props, State> {
  constructor(props: any) {
    super(props);
    this.state = {
      data: {
        number_of_fleets_building: 0,
        number_of_ships_building: 0,
        cost_to_subsidize: 0,
        fleets_building: [],
      },
    };
  }

  async componentDidMount() {
    const data = await lacuna.shipyard.viewBuildQueue({ building_id: this.props.building.id });
    this.setState({
      data: {
        number_of_fleets_building: data.number_of_fleets_building,
        number_of_ships_building: data.number_of_ships_building,
        cost_to_subsidize: data.cost_to_subsidize,
        fleets_building: data.fleets_building,
      },
    });
  }

  async onSubsidizeClick() {
    const res = await lacuna.shipyard.subsidizeBuildQueue({ building_id: this.props.building.id });
    this.setState({
      data: {
        number_of_fleets_building: res.number_of_fleets_building,
        number_of_ships_building: res.number_of_ships_building,
        cost_to_subsidize: res.cost_to_subsidize,
        fleets_building: res.fleets_building,
      },
    });
  }

  render() {
    return (
      <div className='bulma'>
        {this.state.data.fleets_building.length > 0 ? (
          <div className='block'>
            <div className='columns is-vcentered'>
              <div className='column'>
                You may subsidize the whole build queue for {this.state.data.cost_to_subsidize}{' '}
                Essentia.{' '}
              </div>

              <div className='column is-narrow'>
                <button
                  type='button'
                  className='button is-success'
                  onClick={() => this.onSubsidizeClick()}
                >
                  Subsidize
                </button>
              </div>
            </div>
          </div>
        ) : (
          <div className='block'>There are no fleets currently under construction.</div>
        )}

        <div>
          {_.map(this.state.data.fleets_building, (fleet) => (
            <BuildQueueItem fleet={fleet} building={this.props.building} key={fleet.id} />
          ))}
        </div>
      </div>
    );
  }
}

export default BuildQueueTab;
