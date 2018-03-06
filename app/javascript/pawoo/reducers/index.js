import { combineReducers } from 'redux-immutable';
import page from './page';
import reports from './reports';
import suggested_accounts from './suggested_accounts';
import suggestion_tags from './suggestion_tags';
import trend_tags from './trend_tags';

const reducers = {
  page,
  reports,
  suggested_accounts,
  suggestion_tags,
  trend_tags,
};

export default combineReducers(reducers);