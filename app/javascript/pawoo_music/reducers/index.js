import { combineReducers } from 'redux-immutable';
import acct_map from './acct_map';
import album_compose from './album_compose';
import track_compose from './track_compose';
import account_tracks from './account_tracks';

export default combineReducers({
  acct_map,
  album_compose,
  track_compose,
  account_tracks,
});
