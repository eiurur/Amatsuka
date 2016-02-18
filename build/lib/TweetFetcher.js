(function() {
  var TweetFetcher, TwitterClient, chalk, moment, my, path, settings, twitterUtils, _;

  moment = require('moment');

  _ = require('lodash');

  path = require('path');

  chalk = require('chalk');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  my = require(path.resolve('build', 'lib', 'my')).my;

  twitterUtils = require(path.resolve('build', 'lib', 'twitterUtils')).twitterUtils;

  settings = process.env.NODE_ENV === 'production' ? require(path.resolve('build', 'lib', 'configs', 'production')) : require(path.resolve('build', 'lib', 'configs', 'development'));

  module.exports = TweetFetcher = (function() {
    function TweetFetcher(req, res, queryType, maxId, config) {
      this.req = req;
      this.res = res;
      this.queryType = queryType;
      this.maxId = maxId;
      this.config = config;
    }

    TweetFetcher.prototype.getRequestParams = function() {
      var params;
      params = {};
      switch (this.queryType) {
        case 'getListsStatuses':
          params = {
            listIdStr: this.req.params.id,
            maxId: this.maxId,
            count: this.req.params.count,
            includeRetweet: this.config.includeRetweet
          };
          break;
        case 'getHomeTimeline':
        case 'getUserTimeline':
          params = {
            twitterIdStr: this.req.params.id,
            maxId: this.maxId,
            count: this.req.params.count,
            includeRetweet: this.req.query.isIncludeRetweet || this.config.includeRetweet
          };
          break;
        case 'getFavLists':
          params = {
            twitterIdStr: this.req.params.id,
            maxId: this.req.params.maxId,
            count: this.req.params.count
          };
          break;
      }
      return params;
    };

    TweetFetcher.prototype.fetchTweet = function(maxId) {
      var params, twitterClient;
      this.maxId = maxId || this.req.params.maxId;
      params = this.getRequestParams();
      if (_.isEmpty(params)) {
        res.json({
          data: {}
        });
      }
      twitterClient = new TwitterClient(this.req.session.passport.user);
      return twitterClient[this.queryType](params).then((function(_this) {
        return function(tweets) {
          var nextMaxId, tweetsNormalized;
          if (tweets.length === 0) {
            _this.res.json({
              data: []
            });
          }
          nextMaxId = my.decStrNum(_.last(tweets).id_str);
          tweetsNormalized = twitterUtils.normalizeTweets(tweets, _this.config);
          if (!_.isEmpty(tweetsNormalized)) {
            _this.res.json({
              data: tweetsNormalized
            });
          }
          if (_this.maxId === nextMaxId) {
            _this.res.json({
              data: []
            });
          }
          return _this.fetchTweet(nextMaxId);
        };
      })(this))["catch"]((function(_this) {
        return function(error) {
          return _this.res.json({
            error: error
          });
        };
      })(this));
    };

    return TweetFetcher;

  })();

}).call(this);
