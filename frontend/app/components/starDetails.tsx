import React from 'react';
import { Tabber } from 'app/components/tabber';
import SendFleetsTab from 'app/components/starDetails/sendFleetsTab';
import { StarDetailsWindowOptions } from 'app/interfaces/window';
import StarInfoHeader from 'app/components/starDetails/starInfoHeader';
import UnavilableFleetsTab from 'app/components/starDetails/unavailableFleetsTab';
import OrbitingFleetsTab from 'app/components/starDetails/orbitingFleetsTab';
import IncomingFleetsTab from 'app/components/starDetails/incomingFleetsTab';

type Props = {
  options: StarDetailsWindowOptions;
};

class StarDetails extends React.Component<Props> {
  render() {
    return (
      <>
        <StarInfoHeader options={this.props.options} />
        <Tabber
          tabs={[
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

export default StarDetails;
