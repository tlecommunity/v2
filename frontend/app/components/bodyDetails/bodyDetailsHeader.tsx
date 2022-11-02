import React from 'react';
import environment from 'app/environment';
import { BodyDetailsWindowOptions } from 'app/interfaces/window';

type Props = {
  options: BodyDetailsWindowOptions;
};

const BodyDetailsHeader: React.FC<Props> = ({ options }) => (
  <>
    <div className='bulma'>
      <div className='columns is-vcentered mx-4 mb-2'>
        <div className='column is-one-quarter'>
          <div
            className='columns is-centered is-vcentered'
            style={{
              backgroundImage: `url(${environment.getAssetsUrl()}star_system/field.png)`,
              borderRadius: 5,
            }}
          >
            <img
              src={`${environment.getAssetsUrl()}star_system/${options.image}.png`}
              style={{ width: 100, height: 100 }}
            />
          </div>
        </div>

        <div className='column'>
          <h1 className='title is-size-5 mb-2'>{options.name}</h1>

          <div className='mb-2'>
            <ul>
              <li>
                <strong>Type: </strong> {options.type}
              </li>
              <li>
                <strong>Empire: </strong>
              </li>
              <li>
                <strong>Water: </strong>
              </li>
              <li>
                <strong>Planet Size: </strong> {options.size}
              </li>
              <li>
                <strong>X: </strong> {options.x}
              </li>
              <li>
                <strong>Y: </strong> {options.y}
              </li>
              <li>
                <strong>Zone: </strong>
              </li>
              <li>
                <strong>Body ID: </strong> {options.id}
              </li>
              <li>
                <strong>Star: </strong>
              </li>
              <li>
                <strong>Orbit: </strong> {options.orbit}
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </>
);

export default BodyDetailsHeader;
