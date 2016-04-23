(function() {
  var Promise, moment, twitterUtils, util, _;

  _ = require('lodash');

  util = require('util');

  moment = require('moment');

  Promise = require('bluebird');

  twitterUtils = function() {
    return {
      isRT: function(tweet) {
        return _.has(tweet, 'retweeted_status');
      },
      get: function(tweet, key, isRT) {
        var t, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
        t = isRT ? tweet.retweeted_status : tweet;
        switch (key) {
          case 'description':
            return t.user.description;
          case 'display_url':
            return (_ref = t.entities) != null ? (_ref1 = _ref.media) != null ? _ref1[0].display_url : void 0 : void 0;
          case 'entities':
            return t.entities;
          case 'expanded_url':
            return (_ref2 = t.entities) != null ? (_ref3 = _ref2.media) != null ? _ref3[0].expanded_url : void 0 : void 0;
          case 'followers_count':
            return t.user.followers_count;
          case 'friends_count':
            return t.user.friends_count;
          case 'hashtags':
            return (_ref4 = t.entities) != null ? _ref4.hashtags : void 0;
          case 'media_url':
            return _.map(t.extended_entities.media, function(media) {
              return media.media_url;
            });
          case 'media_url_https':
            return _.map(t.extended_entities.media, function(media) {
              return media.media_url_https;
            });
          case 'media_url:orig':
            return _.map(t.extended_entities.media, function(media) {
              return media.media_url + ':orig';
            });
          case 'media_url_https:orig':
            return _.map(t.extended_entities.media, function(media) {
              return media.media_url_https + ':orig';
            });
          case 'video_url':
            return (_ref5 = t.extended_entities) != null ? (_ref6 = _ref5.media[0]) != null ? (_ref7 = _ref6.video_info) != null ? _ref7.variants[0].url : void 0 : void 0 : void 0;
          case 'name':
            return t.user.name;
          case 'profile_banner_url':
            return t.user.profile_banner_url;
          case 'profile_image_url':
            return t.user.profile_image_url;
          case 'profile_image_url_https':
            return t.user.profile_image_url_https;
          case 'statuses_count':
            return t.user.statuses_count;
          case 'screen_name':
            return t.user.screen_name;
          case 'source':
            return t.source;
          case 'text':
            return t.text;
          case 'timestamp_ms':
            return t.timestamp_ms;
          case 'tweet.created_at':
            return t.created_at;
          case 'tweet.favorite_count':
            return t.favorite_count;
          case 'tweet.retweet_count':
            return t.retweet_count;
          case 'tweet.id_str':
            return t.id_str;
          case 'tweet.lang':
            return t.lang;
          case 'user.created_at':
            return t.user.created_at;
          case 'user.id_str':
            return t.user.id_str;
          case 'user.favorite_count':
            return t.favorite_count;
          case 'user.retweet_count':
            return t.retweet_count;
          case 'user.lang':
            return t.user.lang;
          case 'user.url':
            return t.user.url;
          default:
            return null;
        }
      },
      normalizeTweets: function(tweets, config) {
        if (config == null) {
          config = {};
        }
        config.ngUsername || (config.ngUsername = []);
        config.ngWord || (config.ngWord = []);
        config.favLowerLimit || (config.favLowerLimit = 0);
        console.log(config);
        return _.reject(tweets, (function(_this) {
          return function(tweet) {
            var includeNgUser, includeNgWord, isFavLowerLimit, isOnlyTextTweet;
            tweet = _.has(tweet, 'tweetStr') ? JSON.parse(tweet.tweetStr) : tweet;
            includeNgUser = config.ngUsername.some(function(element, index) {
              return _this.get(tweet, 'screen_name', _this.isRT(tweet)).indexOf(element.text) !== -1;
            });
            includeNgWord = config.ngWord.some(function(element, index) {
              return _this.get(tweet, 'text', _this.isRT(tweet)).indexOf(element.text) !== -1;
            });
            isFavLowerLimit = _this.get(tweet, 'tweet.favorite_count', _this.isRT(tweet)) < config.favLowerLimit;
            isOnlyTextTweet = !_.has(tweet, 'extended_entities') || _.isEmpty(tweet.extended_entities.media);
            return includeNgUser || includeNgWord || isFavLowerLimit || isOnlyTextTweet;
          };
        })(this));
      }
    };
  };

  exports.twitterUtils = twitterUtils();

}).call(this);
