import React from 'react';
import CountdownTimer from 'app/components/countdownTimer';
import ShipImage from 'app/components/menu/shipImage';
import Icon from 'app/components/menu/icon';
import { FleetBeingWorkedOn } from 'app/interfaces/shipyard';
import { Building } from 'app/interfaces/building';
import { commify, reduceNumber } from 'app/util';

type Props = {
  fleet: FleetBeingWorkedOn;
  building: Building;
};

const BuildQueueItem: React.FC<Props> = ({ fleet, building }) => (
  <div className='bulma'>
    <div className='columns is-vcentered'>
      <div className='column is-narrow'>
        <ShipImage type={fleet.type} name={fleet.type_human} />
      </div>

      <div className='column'>
        <h1 className='title is-size-5 mb-2'>
          {fleet.type_human} ({fleet.quantity})
        </h1>

        <div className='mb-2'>
          <span className='tag is-info'>Building</span>
        </div>

        <div className='mb-2'>
          <span className='has-text-weight-bold'>Attributes: </span> Speed:{' '}
          <span title={commify(fleet.attributes.speed)}>
            {reduceNumber(fleet.attributes.speed)}
          </span>
          , Hold Size:{' '}
          <span title={commify(fleet.attributes.hold_size)}>
            {reduceNumber(fleet.attributes.hold_size)}
          </span>
          , Stealth:{' '}
          <span title={commify(fleet.attributes.stealth)}>
            {reduceNumber(fleet.attributes.stealth)}
          </span>
          , Combat:{' '}
          <span title={commify(fleet.attributes.combat)}>
            {reduceNumber(fleet.attributes.combat)}
          </span>
          , Berth Level:{' '}
          <span title={commify(fleet.attributes.berth_level)}>
            {reduceNumber(fleet.attributes.berth_level)}
          </span>
          , Max Occupants:{' '}
          <span title={commify(fleet.attributes.max_occupants)}>
            {reduceNumber(fleet.attributes.max_occupants)}
          </span>
        </div>

        <div className='mb-2'>
          <span className='has-text-weight-bold'>Remaining: </span>
          <CountdownTimer endDate={fleet.date_completed} />
        </div>
      </div>

      <div className='column is-narrow'>
        <div className='field'>
          <button type='button' className='button is-success'>
            Subsidize {fleet.quantity} <Icon style='essentia' />
          </button>
        </div>
      </div>
    </div>

    <hr />
  </div>
);

export default BuildQueueItem;
