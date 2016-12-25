(function() {
  var TweetFetcher, TwitterClient, _, chalk, configMiddleware, my, path;

  _ = require('lodash');

  path = require('path');

  chalk = require('chalk');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  TweetFetcher = require(path.resolve('build', 'lib', 'TweetFetcher'));

  my = require(path.resolve('build', 'lib', 'my')).my;

  configMiddleware = require(path.resolve('build', 'app', 'routes', 'middlewares', 'configMiddleware'));

  module.exports = function(app) {
    return app.get('/api/timeline/:id/:maxId?/:count?', configMiddleware.getConfig, function(req, res) {
      var maxId, queryType;
      queryType = req.params.id === 'home' ? 'getHomeTimeline' : 'getUserTimeline';
      maxId = _.isNaN(req.params.maxId - 0) ? null : req.params.maxId - 0;
      return new TweetFetcher(req, res, queryType, maxId, req.config).fetchTweet();
    });
  };

}).call(this);
