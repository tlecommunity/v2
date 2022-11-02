import React from 'react';
import _ from 'lodash';
import SpacePort from 'app/services/spacePort';
import BodyRPCStore from 'app/stores/rpc/body';
import { StarDetailsWindowOptions } from 'app/interfaces/window';
import { Fleet } from 'app/interfaces/spacePort';
import FleetItem from 'app/components/spacePort/fleetItem';

type Props = {
  options: StarDetailsWindowOptions;
};

type State = {
  fleets: Fleet[];
};

class UnavilableFleetsTab extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      fleets: [],
    };
  }

  async componentDidMount() {
    const { unavailable } = await SpacePort.viewUnavailableFleets({
      body_id: BodyRPCStore.id,
      target: { star_id: this.props.options.id },
    });
    this.setState({ fleets: unavailable });
  }

  render() {
    return (
      <div>
        {_.map(this.state.fleets, (fleet) => (
          <FleetItem fleet={fleet} key={fleet.id} />
        ))}
      </div>
    );
  }
}

export default UnavilableFleetsTab;
