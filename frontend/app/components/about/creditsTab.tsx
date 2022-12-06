import React from 'react';
import _ from 'lodash';
import lacuna from 'app/lacuna';
import { types } from '@tlecommunity/client';
import CreditsSection from 'app/components/about/creditsSection';

type State = {
  credits: types.Stats.CreditsResult;
};

class CreditsTab extends React.Component<any, State> {
  constructor(props: any) {
    super(props);
    this.state = {
      credits: [],
    };
  }

  async componentDidMount() {
    this.setState({ credits: await lacuna.stats.credits() });
  }

  render() {
    return (
      <div className='bulma'>
        <h1 className='title is-size-3'>Credits</h1>

        {_.map(this.state.credits, (section) => {
          return _.map(section, (names, header) => {
            return <CreditsSection key={header} header={header} names={names} />;
          });
        })}
      </div>
    );
  }
}

export default CreditsTab;
