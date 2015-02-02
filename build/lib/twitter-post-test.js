(function() {
  var Promise, TLProvider, TwitterCilent, my, settings, _;

  _ = require('lodash');

  Promise = require('es6-promise').Promise;

  my = require('./my').my;

  TLProvider = require('./model').TLProvider;

  TwitterCilent = require('./TwitterClient');

  settings = (process.env.NODE_ENV === "production" ? require('./configs/production') : require('./configs/development')).settings;

  exports.twitterPostTest = function(user) {
    var TARGET_TWEET_ID_STR, TARGET_TWITTER_ID_STR, retweetIdStr, twitterClient;
    TARGET_TWITTER_ID_STR = '2686409167';
    TARGET_TWEET_ID_STR = '535402680378597377';
    retweetIdStr = '';
    twitterClient = new TwitterCilent(user);
    return new Promise(function(resolve, reject) {
      return twitterClient.retweetStatus({
        tweetIdStr: TARGET_TWEET_ID_STR
      }).then(function(data) {
        console.log('\nretweetStatus -> ', data.retweeted_status.id_str);
        retweetIdStr = data.id_str;
        console.log(retweetIdStr);
        return twitterClient.createFav({
          tweetIdStr: data.retweeted_status.id_str
        });
      }).then(function(data) {
        console.log('\n createFav -> ', data);
        console.log(retweetIdStr);
        return twitterClient.destroyFav({
          tweetIdStr: retweetIdStr
        });
      }).then(function(data) {
        console.log("\n destroyFav ->  " + data.id_str + " , " + data.text);
        return twitterClient.destroyStatus({
          tweetIdStr: data.id_str
        });
      }).then(function(data) {
        console.log("\n getListsCreate ->  " + data.id_str + " , " + data.text);
        return twitterClient.getFavList({
          twitterIdStr: TARGET_TWITTER_ID_STR
        });
      }).then(function(data) {
        var latestFavIdStr;
        latestFavIdStr = data[0].id_str;
        console.log('\n getFavList latestFavIdStr -> ', latestFavIdStr);
        return resolve(data);
      })["catch"](function(err) {
        console.log('twitter tweet test err =======> ', err);
        return reject(err);
      });
    });
  };

}).call(this);
