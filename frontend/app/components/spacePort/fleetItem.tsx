import React from 'react';
import { Fleet } from 'app/interfaces/spacePort';
import { reduceNumber, commify } from 'app/util';
import CountdownTimer from '../countdownTimer';
import ShipImage from 'app/components/menu/shipImage';

type Props = {
  fleet: Fleet;
  children?: React.ReactElement;
};

class FleetItem extends React.Component<Props> {
  render() {
    const fleet = this.props.fleet;

    return (
      <div className='bulma'>
        <div className='columns is-vcentered'>
          <div className='column is-narrow'>
            <ShipImage type={fleet.details.type} name={fleet.details.type_human} />
          </div>

          <div className='column'>
            <h1 className='title is-size-5 mb-2'>
              [{fleet.quantity} x {fleet.details.type_human}] {fleet.details.name} (ID: {fleet.id})
            </h1>

            <div className='mb-2'>
              <span className='tag is-info'>{fleet.task}</span>
            </div>

            {fleet.task === 'Travelling' && fleet.from && fleet.to && fleet.date_arrives ? (
              <div className='mb-2'>
                <span className='has-text-weight-bold'>Travel: </span> From: {fleet.from.name}, To:{' '}
                {fleet.to.name}, Arriving: <CountdownTimer endDate={fleet.date_arrives} />
              </div>
            ) : (
              ''
            )}

            {fleet.task === 'Defend' && fleet.from ? (
              <div className='mb-2'>
                <span className='has-text-weight-bold'>Owner: </span> {fleet.from.empire.name}
              </div>
            ) : (
              ''
            )}

            <div className='mb-2'>
              <span className='has-text-weight-bold'>Attributes: </span> Speed:{' '}
              <span title={commify(fleet.details.speed)}>{reduceNumber(fleet.details.speed)}</span>,{' '}
              Hold Size:{' '}
              <span title={commify(fleet.details.hold_size)}>
                {reduceNumber(fleet.details.hold_size)}
              </span>
              , Stealth:{' '}
              <span title={commify(fleet.details.stealth)}>
                {reduceNumber(fleet.details.stealth)}
              </span>{' '}
              , Combat:{' '}
              <span title={commify(fleet.details.combat)}>
                {reduceNumber(fleet.details.combat)}
              </span>{' '}
              , Berth Level:{' '}
              <span title={commify(fleet.details.berth_level)}>
                {reduceNumber(fleet.details.berth_level)}
              </span>{' '}
              , Max Occupants:{' '}
              <span title={commify(fleet.details.max_occupants)}>
                {reduceNumber(fleet.details.max_occupants)}
              </span>
            </div>

            {fleet.reason ? <div className='mb-2 has-text-danger'>{fleet.reason[1]}</div> : ''}
            <div className='mb-2'>{this.props.children}</div>
          </div>
        </div>

        <hr />
      </div>
    );
  }
}

export default FleetItem;
