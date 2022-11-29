import { Lacuna } from '@tlecommunity/client';

const lacuna = new Lacuna({ serverUrl: '' });
lacuna.log.setLogLevel('debug');

export default lacuna;
