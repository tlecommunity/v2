// See: https://github.com/rackt/react-router/blob/master/docs/guides/advanced/NavigatingOutsideOfComponents.md

import createHistory from 'history/lib/createBrowserHistory';

import WindowActions from './actions/window';

const history = createHistory();

WindowActions.navigate.listen((url) => {
  history.replaceState(null, url);
});

export default history;
