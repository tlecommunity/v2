import React from 'react';
import environment from 'app/environment';
import { StarDetailsWindowOptions } from 'app/interfaces/window';

type Props = {
  options: StarDetailsWindowOptions;
};

const StarInfoHeader: React.FC<Props> = ({ options }) => (
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
              src={`${environment.getAssetsUrl()}star_map/${options.color}.png`}
              style={{ width: 100, height: 100 }}
            />
          </div>
        </div>

        <div className='column'>
          <h1 className='title is-size-5 mb-2'>{options.name}</h1>

          <div className='mb-2'>
            <ul>
              <li>
                <strong>X: </strong> {options.x}
              </li>
              <li>
                <strong>Y: </strong> {options.y}
              </li>
              <li>
                <strong>Zone: </strong> {options.zone}
              </li>
              <li>
                <strong>Star ID: </strong> {options.id}
              </li>
              <li>
                <strong>Net Influence: </strong> {options.influence}
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </>
);

export default StarInfoHeader;
