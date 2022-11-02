import React from 'react';
import _ from 'lodash';
import SpacePort from 'app/services/spacePort';
import BodyRPCStore from 'app/stores/rpc/body';
import { StarDetailsWindowOptions } from 'app/interfaces/window';
import { Fleet } from 'app/interfaces/spacePort';
import FleetItem from 'app/components/spacePort/fleetItem';
import { int } from 'app/util';

type Props = {
  options: StarDetailsWindowOptions;
};

type State = {
  fleets: Fleet[];
  quantities: { [index: number]: string };
};

class SendFleetsTab extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      fleets: [],
      quantities: {},
    };
  }

  async componentDidMount() {
    const { available } = await SpacePort.viewAvailableFleets({
      body_id: BodyRPCStore.id,
      target: { star_id: this.props.options.id },
    });
    this.setState({ fleets: available });
  }

  async sendFleet(fleetId: number, quantity: number) {
    const res = await SpacePort.sendFleet({
      fleet_id: fleetId,
      target: { star_id: this.props.options.id },
      quantity,
    });
    console.log(res);
  }

  updateQuantity(e: React.ChangeEvent<HTMLInputElement>, fleetId: number) {
    this.setState({ quantities: { ...this.state.quantities, ...{ [fleetId]: e.target.value } } });
  }

  render() {
    return (
      <div>
        {_.map(this.state.fleets, (fleet) => (
          <FleetItem fleet={fleet} key={fleet.id}>
            <div className='bulma'>
              <div className='field is-grouped'>
                <div className='control'>
                  <input
                    className='input'
                    type='number'
                    placeholder='Quantity'
                    onChange={(e) => this.updateQuantity(e, fleet.id)}
                    value={this.state.quantities[fleet.id]}
                  />
                </div>
                <div className='control'>
                  <button
                    type='button'
                    className='button is-success'
                    onClick={() => this.sendFleet(fleet.id, int(this.state.quantities[fleet.id]))}
                  >
                    Send
                  </button>
                </div>
              </div>
            </div>
          </FleetItem>
        ))}
      </div>
    );
  }
}

export default SendFleetsTab;
