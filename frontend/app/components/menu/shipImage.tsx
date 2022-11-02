import React from 'react';
import environment from 'app/environment';

type Props = {
  type: string;
  name: string;
};

const ShipImage: React.FC<Props> = ({ type, name }) => (
  <div
    className='box'
    style={{
      width: 100,
      background: `transparent url(${environment.getAssetsUrl()}star_system/field.png) no-repeat center`,
      textAlign: 'center',
    }}
  >
    <img
      src={`${environment.getAssetsUrl()}ships/${type}.png`}
      className='image'
      alt={name}
      title={name}
    />
  </div>
);

export default ShipImage;
