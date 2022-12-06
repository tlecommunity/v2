import React from 'react';
import lacuna from 'app/lacuna';
import { Building } from 'app/interfaces';
import { types } from '@tlecommunity/client';
type Fleet = types.SpacePort.Fleet;
import _ from 'lodash';
import FleetItem from 'app/components/spacePort/fleetItem';
import BodyRPCStore from 'app/stores/rpc/body';

type Props = {
  building: Building;
};

type State = {
  fleets: Fleet[];
};

class OrbitingFleetsTab extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      fleets: [],
    };
  }

  async componentDidMount() {
    console.log(this.props.building.id);
    const res = await lacuna.spacePort.viewOrbitingFleets({
      target: { body_id: BodyRPCStore.id },
    });
    this.setState({
      fleets: res.orbiting,
    });
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

export default OrbitingFleetsTab;
