import { Lacuna } from '@tlecommunity/client';

const lacuna = new Lacuna({ serverUrl: 'http://localhost:8080' });
lacuna.log.setLogLevel('info');

export default lacuna;
