import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect }   from 'react-redux';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import { refreshTrendTags } from '../../actions/trend_tags';
import HashtagLink from '../../components/hashtag_link';
import TagBox from '../../components/tag_box';
import { changeTargetColumn } from '../../actions/column';

const messages = defineMessages({
  title: { id: 'trend_tags.title', defaultMessage: 'Suggested tags' },
});

const mapStateToProps = state => ({
  tags: state.getIn(['trend_tags', 'tags']),
  target: state.getIn(['pawoo_music', 'column', 'target']),
});

@injectIntl
@connect(mapStateToProps)
export default class TrendTags extends ImmutablePureComponent {

  static propTypes = {
    tags: ImmutablePropTypes.list.isRequired,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount () {
    const { dispatch } = this.props;

    dispatch(refreshTrendTags());
    this.interval = setInterval(() => {
      dispatch(refreshTrendTags());
    }, 1000 * 60 * 20);
  }

  componentWillUnmount () {
    clearInterval(this.interval);
  }

  handleClick = () => {
    const { dispatch } = this.props;
    dispatch(changeTargetColumn('lobby'));
  }

  render () {
    const { tags, intl } = this.props;

    return (
      <TagBox className='trend-tags' heading={intl.formatMessage(messages.title)}>
        <ul>
          {tags.map(tag => (
            <li key={tag.get('name')} className='hashtag'>
              <HashtagLink hashtag={tag.get('name')} onClick={this.handleClick} />
            </li>
          ))}
        </ul>
      </TagBox>
    );
  }

};