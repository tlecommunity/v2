import React from 'react';
import _ from 'lodash';
import lacuna from 'app/lacuna';
import { StarDetailsWindowOptions } from 'app/interfaces/window';
import { types } from '@tlecommunity/client';
type Fleet = types.SpacePort.Fleet;
import FleetItem from 'app/components/spacePort/fleetItem';

type Props = {
  options: StarDetailsWindowOptions;
};

type State = {
  fleets: Fleet[];
};

class IncomingFleetsTab extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      fleets: [],
    };
  }

  async componentDidMount() {
    const { incoming } = await lacuna.spacePort.viewIncomingFleets({
      target: { star_id: this.props.options.id },
    });
    this.setState({ fleets: incoming });
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

export default IncomingFleetsTab;
