import React from 'react';
import _ from 'lodash';
import withBuildingTabs from 'app/hocs/withBuildingTabs';
import ViewFleetsTab from 'app/components/spacePort/viewFleetsTab';
import TravellingFleetsTab from 'app/components/spacePort/travellingFleetsTab';
import OrbitingFleetsTab from 'app/components/spacePort/orbitingFleetsTab';
import IncomingFleetsTab from 'app/components/spacePort/incomingFleetsTab';

export default withBuildingTabs({
  getTabs(building) {
    return [
      {
        title: 'Travelling',
        component: () => <TravellingFleetsTab building={building} />,
      },
      {
        title: 'View',
        component: () => <ViewFleetsTab building={building} />,
      },
      {
        title: 'Orbiting',
        component: () => <OrbitingFleetsTab building={building} />,
      },
      {
        title: 'Incoming',
        component: () => <IncomingFleetsTab building={building} />,
      },
      {
        title: 'Battle Logs',
        component: () => <p>Not Yet Implemented</p>,
      },
      {
        title: 'Send',
        component: () => <p>Not Yet Implemented</p>,
      },
    ];
  },
});
