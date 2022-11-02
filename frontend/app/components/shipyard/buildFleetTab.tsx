import React from 'react';
import _ from 'lodash';
import { Building } from 'app/interfaces/building';
import BuildFleetItem from 'app/components/shipyard/buildFleet/item';
import Shipyard from 'app/services/shipyard';
import { ShipyardGetBuildableResponse } from 'app/interfaces/shipyard';

type Props = {
  building: Building;
};

type State = {
  show: string; // TODO
  filter: string; // TODO
  autoSelect: string; // TODO
  data: ShipyardGetBuildableResponse;
};

class BuildFleetTab extends React.Component<Props, State> {
  constructor(props: any) {
    super(props);
    this.state = {
      show: 'now',
      filter: 'all',
      autoSelect: 'this',
      data: {
        build_queue_max: 0,
        build_queue_used: 0,
        buildable: {},
        docks_available: 0,
      },
    };
  }

  async componentDidMount() {
    const res = await Shipyard.getBuildable({ building_id: this.props.building.id });
    this.setState({ data: res });
  }

  handleShowChange(e: React.ChangeEvent<HTMLSelectElement>) {
    this.setState({
      show: e.target.value,
    });
  }

  handleFilterChange(e: React.ChangeEvent<HTMLInputElement>) {
    this.setState({
      filter: e.target.value,
    });
  }

  handleAutoSelectChange(e: React.ChangeEvent<HTMLInputElement>) {
    this.setState({
      autoSelect: e.target.value,
    });
  }

  render() {
    const fleetItems = [];
    let fleetTypes = Object.keys(this.state.data.buildable).sort();

    // Filter based on buildable now or later.
    if (this.state.show === 'now') {
      fleetTypes = _.filter(
        fleetTypes,
        (fleetType) => this.state.data.buildable[fleetType].can === 1
      );
    } else if (this.state.show === 'later') {
      fleetTypes = _.filter(
        fleetTypes,
        (fleetType) => this.state.data.buildable[fleetType].can === 0
      );
    }

    // // Filter based on ship type
    // if (this.state.filter !== 'all') {
    //   const { filter } = this.state;
    //   fleetTypes = _.filter(fleetTypes, (fleetType) =>
    //     _.find(buildable[fleetType].tags, (o) => o === filter)
    //   );
    // }

    fleetTypes.sort();

    for (let i = 0; i < fleetTypes.length; i++) {
      fleetItems.push();
    }

    return (
      <div className='bulma'>
        <div className='block'>
          <div className='columns is-vcentered'>
            <div className='column'>
              There are {this.state.data.docks_available} docks available for new ships. You can
              queue {this.state.data.build_queue_max - this.state.data.build_queue_used} ships.
            </div>

            <div className='column is-narrow'>
              <div className='field'>
                <div className='control'>
                  <div className='select is-small'>
                    <select value={this.state.show} onChange={(e) => this.handleShowChange(e)}>
                      <option value='all'>All</option>
                      <option value='now'>Now</option>
                      <option value='later'>Later</option>
                    </select>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/*
        <div className='ui grid'>
          <div className='six wide column'>
            Use{' '}
            <select className='ui dropdown' ref='autoSelect' onChange={this.handleAutoSelectChange}>
              <option value='this'>This Only</option>
              <option value='all' selected>
                All
              </option>
              <option value='equal_or_higher'>Same or Higher Level</option>
              <option value='equal'>Same Level</option>
            </select>
          </div>

          <div className='five wide column'>
            Filter{' '}
            <select className='ui dropdown' ref='filter' onChange={this.handleFilterChange}>
              <option value='all' selected>
                All
              </option>
              <option value='Trade'>Trade</option>
              <option value='Mining'>Mining</option>
              <option value='Intelligence'>Intelligence</option>
              <option value='SupplyChain'>Supply Chain</option>
              <option value='WasteChain'>Waste Chain</option>
              <option value='War'>War</option>
              <option value='Colonization'>Colonization</option>
              <option value='Exploration'>Exploration</option>
            </select>
          </div>

          <div className='five wide column'>
            Show{' '}
            <select className='ui dropdown' ref='show' onChange={this.handleShowChange}>
              <option value='all'>All</option>
              <option value='now' selected>
                Can build now
              </option>
              <option value='later'>Can build later</option>
            </select>
          </div>
        </div>

        <div className='ui divider' /> */}

        <div>
          {_.map(fleetTypes, (type) => (
            <BuildFleetItem
              key={type}
              type={type}
              fleet={this.state.data.buildable[type]}
              building={this.props.building}
            />
          ))}
        </div>
      </div>
    );
  }
}

export default BuildFleetTab;
