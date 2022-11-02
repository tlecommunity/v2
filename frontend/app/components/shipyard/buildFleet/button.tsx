import { Building } from 'app/interfaces/building';
import React from 'react';
import Shipyard from 'app/services/shipyard';
import { int } from 'app/util';

type Props = {
  building: Building;
  type: string;
};

type State = {
  quantity: string;
};

class BuildButton extends React.Component<Props, State> {
  constructor(props: any) {
    super(props);
    this.state = {
      quantity: '1',
    };
  }

  updateQuantity(e: React.ChangeEvent<HTMLInputElement>) {
    this.setState({ quantity: e.target.value });
  }

  async buildFleet() {
    console.log(`Building ${this.state.quantity} of ${this.props.type}`);
    const res = await Shipyard.buildFleet({
      building_ids: [this.props.building.id],
      quantity: int(this.state.quantity),
      type: this.props.type,
      auto_select: 'this', // TODO: this is wrong
    });
    console.log(res);
  }

  render() {
    return (
      <div className='bulma'>
        <div className='field is-grouped'>
          <div className='control'>
            <input
              className='input'
              type='number'
              placeholder='Quantity'
              onChange={(e) => this.updateQuantity(e)}
              value={this.state.quantity}
            />
          </div>
          <div className='control'>
            <button type='button' className='button is-success' onClick={() => this.buildFleet()}>
              Build
            </button>
          </div>
        </div>
      </div>
    );
  }
}

export default BuildButton;
