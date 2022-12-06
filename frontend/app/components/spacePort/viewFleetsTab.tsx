import React from 'react';

import constants from 'app/constants';
import lacuna from 'app/lacuna';
import { Building } from 'app/interfaces';
import { types } from '@tlecommunity/client';
type Fleet = types.SpacePort.Fleet;
import _ from 'lodash';

import FleetItem from 'app/components/spacePort/fleetItem';

type Props = {
  building: Building;
};

type State = {
  task: string;
  tag: string;
  type: string;
  name: string;
  fleets: Fleet[];
  numberOfFleets: number;
  docksAvailable: number;
  maxShips: number;
  currentShips: number;
};

class ViewFleetsTab extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      task: 'all',
      tag: 'all',
      type: 'all',
      name: '',
      fleets: [],
      numberOfFleets: 0,
      docksAvailable: 0,
      maxShips: 0,
      currentShips: 0,
    };
  }

  async componentDidMount() {
    const res = await lacuna.spacePort.viewAllFleets({ building_id: this.props.building.id });
    this.setState({
      fleets: res.fleets,
      numberOfFleets: res.number_of_fleets,
      docksAvailable: res.docks_available,
      maxShips: res.max_ships,
      currentShips: res.max_ships - res.docks_available,
    });
  }

  render() {
    let fleets = this.state.fleets;

    if (this.state.task !== 'all') {
      fleets = _.filter(fleets, (fleet) => fleet.task === this.state.task);
    }

    if (this.state.type !== 'all') {
      fleets = _.filter(fleets, (fleet) => fleet.details.type_human === this.state.type);
    }

    if (this.state.tag !== 'all') {
      fleets = _.filter(fleets, (fleet) => fleet.details.build_tags.includes(this.state.tag));
    }

    return (
      <div className='bulma'>
        <div className='columns'>
          <div className='column'>
            <div className='field'>
              <label className='label'>Task</label>
              <div className='control'>
                <div className='select is-small'>
                  <select onChange={(e) => this.setState({ task: e.target.value })}>
                    <option value='all'>All</option>
                    {_.map(constants.FLEET_TASKS, (task) => (
                      <option value={task} key={task}>
                        {task}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
            </div>
          </div>

          <div className='column'>
            <div className='field'>
              <label className='label'>Tag</label>
              <div className='control'>
                <div className='select is-small'>
                  <select onChange={(e) => this.setState({ tag: e.target.value })}>
                    <option value='all'>All</option>
                    {_.map(constants.FLEET_TAGS, (tag) => (
                      <option value={tag} key={tag}>
                        {tag}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
            </div>
          </div>

          <div className='column'>
            <div className='field'>
              <label className='label'>Type</label>
              <div className='control'>
                <div className='select is-small'>
                  <select onChange={(e) => this.setState({ type: e.target.value })}>
                    <option value='all'>All</option>
                    {_.map(constants.FLEET_TYPES, (type) => (
                      <option value={type} key={type}>
                        {type}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
            </div>
          </div>

          <div className='column'>
            <div className='field'>
              <label className='label' htmlFor='name'>
                Name
              </label>
              <div className='control'>
                <input
                  type='text'
                  name='name'
                  onChange={(e) => this.setState({ name: e.target.value })}
                  className='input is-small'
                />
              </div>
            </div>
          </div>
        </div>

        <hr />

        <div className='block'>
          {this.state.docksAvailable} docks available. {this.state.currentShips} used out of{' '}
          {this.state.maxShips} across {this.state.numberOfFleets} fleets.
        </div>

        <div>
          {_.map(fleets, (fleet) => (
            <FleetItem fleet={fleet} key={fleet.id} />
          ))}
        </div>
      </div>
    );
  }
}

export default ViewFleetsTab;
