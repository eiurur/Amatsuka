(function() {
  var Promise, _, moment, twitterUtils, util;

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
        var ref, ref1, ref2, ref3, ref4, ref5, ref6, ref7, t;
        t = isRT ? tweet.retweeted_status : tweet;
        switch (key) {
          case 'description':
            return t.user.description;
          case 'display_url':
            return (ref = t.entities) != null ? (ref1 = ref.media) != null ? ref1[0].display_url : void 0 : void 0;
          case 'entities':
            return t.entities;
          case 'expanded_url':
            return (ref2 = t.entities) != null ? (ref3 = ref2.media) != null ? ref3[0].expanded_url : void 0 : void 0;
          case 'followers_count':
            return t.user.followers_count;
          case 'friends_count':
            return t.user.friends_count;
          case 'hashtags':
            return (ref4 = t.entities) != null ? ref4.hashtags : void 0;
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
            return (ref5 = t.extended_entities) != null ? (ref6 = ref5.media[0]) != null ? (ref7 = ref6.video_info) != null ? ref7.variants[0].url : void 0 : void 0 : void 0;
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
        config.retweetLowerLimit || (config.retweetLowerLimit = 0);
        config.likeLowerLimit || (config.likeLowerLimit = 0);
        return _.reject(tweets, (function(_this) {
          return function(tweet) {
            var includeNgUser, includeNgWord, isLikeLowerLimit, isOnlyTextTweet, isRetweetLowerLimit;
            tweet = _.has(tweet, 'tweetStr') ? JSON.parse(tweet.tweetStr) : tweet;
            tweet = _this.isRT(tweet) ? tweet.retweeted_status : tweet;
            includeNgUser = config.ngUsername.some(function(element, index) {
              return tweet.user.screen_name.indexOf(element.text) !== -1;
            });
            includeNgWord = config.ngWord.some(function(element, index) {
              return tweet.text.indexOf(element.text) !== -1;
            });
            isRetweetLowerLimit = tweet.retweet_count < config.retweetLowerLimit;
            isLikeLowerLimit = tweet.favorite_count < config.likeLowerLimit;
            isOnlyTextTweet = !_.has(tweet, 'extended_entities') || _.isEmpty(tweet.extended_entities.media);
            return includeNgUser || includeNgWord || isRetweetLowerLimit || isLikeLowerLimit || isOnlyTextTweet;
          };
        })(this));
      }
    };
  };

  exports.twitterUtils = twitterUtils();

}).call(this);
