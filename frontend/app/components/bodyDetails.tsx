import React from 'react';
import { Tabber } from 'app/components/tabber';
import { BodyDetailsWindowOptions } from 'app/interfaces/window';
import ResourcesTab from 'app/components/bodyDetails/resourcesTab';
import SendFleetsTab from 'app/components/bodyDetails/sendFleetsTab';
import UnavilableFleetsTab from 'app/components/bodyDetails/unavailableFleetsTab';
import IncomingFleetsTab from 'app/components/bodyDetails/incomingFleetsTab';
import OrbitingFleetsTab from 'app/components/bodyDetails/orbitingFleetsTab';
import BodyDetailsHeader from 'app/components/bodyDetails/bodyDetailsHeader';

type Props = {
  options: BodyDetailsWindowOptions;
};

class BodyDetails extends React.Component<Props> {
  render() {
    return (
      <>
        <BodyDetailsHeader options={this.props.options} />
        <Tabber
          tabs={[
            {
              title: 'Resources',
              component: () => <ResourcesTab options={this.props.options} />,
            },
            {
              title: 'Send',
              component: () => <SendFleetsTab options={this.props.options} />,
            },
            {
              title: 'Unavailable',
              component: () => <UnavilableFleetsTab options={this.props.options} />,
            },
            {
              title: 'Orbiting',
              component: () => <OrbitingFleetsTab options={this.props.options} />,
            },
            {
              title: 'Incoming',
              component: () => <IncomingFleetsTab options={this.props.options} />,
            },
            {
              title: 'Laws',
              component: () => <p>Not Yet Implemented</p>,
            },
          ]}
        />
      </>
    );
  }
}

export default BodyDetails;
