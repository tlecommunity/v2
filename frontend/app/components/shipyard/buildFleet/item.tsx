import React from 'react';
import Icon from 'app/components/menu/icon';
import ShipImage from 'app/components/menu/shipImage';
import BuildFleetButton from 'app/components/shipyard/buildFleet/button';
import { types } from '@tlecommunity/client';
import { commify, reduceNumber, formatTime } from 'app/util';

type Props = {
  building: types.Building.Building;
  type: string;
  fleet: types.Shipyard.BuildableFleet;
};

const BuildFleetItem: React.FC<Props> = ({ type, fleet, building }) => (
  <div className='bulma'>
    <div className='columns'>
      <div className='column is-narrow'>
        <ShipImage type={type} name={fleet.type_human} />
      </div>

      <div className='column'>
        <h1 className='title is-size-5 mb-2'>{fleet.type_human}</h1>

        <div className='mb-2'>
          <span className='has-text-weight-bold'>Cost: </span> <Icon style='food' />{' '}
          <span title={commify(fleet.cost.food)}>{reduceNumber(fleet.cost.food)}</span>{' '}
          <Icon style='ore' />{' '}
          <span title={commify(fleet.cost.ore)}>{reduceNumber(fleet.cost.ore)}</span>{' '}
          <Icon style='water' />{' '}
          <span title={commify(fleet.cost.water)}>{reduceNumber(fleet.cost.water)}</span>{' '}
          <Icon style='energy' />{' '}
          <span title={commify(fleet.cost.energy)}>{reduceNumber(fleet.cost.energy)}</span>{' '}
          <Icon style='time' /> {formatTime(fleet.cost.seconds)}
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

        {fleet.can === 1 ? (
          <div className='mb-2'>
            <BuildFleetButton building={building} type={type} />
          </div>
        ) : (
          ''
        )}

        {fleet.can === 0 && fleet.reason ? (
          <div className='sixteen wide column'>
            <span
              style={{
                float: 'right',
                color: 'red',
              }}
              title={fleet.reason[1]}
            >
              {fleet.reason[1]}
            </span>
          </div>
        ) : (
          ''
        )}
      </div>
    </div>

    <hr />
  </div>
);

export default BuildFleetItem;
