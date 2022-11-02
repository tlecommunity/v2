import React from 'react';
import _ from 'lodash';
import SpacePort from 'app/services/spacePort';
import { BodyDetailsWindowOptions } from 'app/interfaces/window';
import { Fleet } from 'app/interfaces/spacePort';
import FleetItem from 'app/components/spacePort/fleetItem';

type Props = {
  options: BodyDetailsWindowOptions;
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
    const { orbiting } = await SpacePort.viewOrbitingFleets({
      target: { body_id: this.props.options.id },
    });
    this.setState({ fleets: orbiting });
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
