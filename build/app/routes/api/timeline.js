(function() {
  var ConfigProvider, TweetFetcher, TwitterClient, _, chalk, my, path;

  _ = require('lodash');

  path = require('path');

  chalk = require('chalk');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  TweetFetcher = require(path.resolve('build', 'lib', 'TweetFetcher'));

  my = require(path.resolve('build', 'lib', 'my')).my;

  ConfigProvider = require(path.resolve('build', 'lib', 'model')).ConfigProvider;

  module.exports = function(app) {
    return app.get('/api/timeline/:id/:maxId?/:count?', function(req, res) {
      return ConfigProvider.findOneById({
        twitterIdStr: req.session.passport.user._json.id_str
      }, function(err, data) {
        var config, maxId, queryType;
        config = _.isNull(data) ? {} : JSON.parse(data.configStr);
        queryType = req.params.id === 'home' ? 'getHomeTimeline' : 'getUserTimeline';
        maxId = _.isNaN(req.params.maxId - 0) ? null : req.params.maxId - 0;
        return new TweetFetcher(req, res, queryType, maxId, config).fetchTweet();
      });
    });
  };

}).call(this);
