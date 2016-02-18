(function() {
  var ConfigProvider, TweetFetcher, TwitterClient, path, _;

  _ = require('lodash');

  path = require('path');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  TweetFetcher = require(path.resolve('build', 'lib', 'TweetFetcher'));

  ConfigProvider = require(path.resolve('build', 'lib', 'model')).ConfigProvider;

  module.exports = function(app) {
    return app.get('/api/timeline/:id/:maxId?/:count?', function(req, res) {
      return ConfigProvider.findOneById({
        twitterIdStr: req.session.passport.user._json.id_str
      }, function(err, data) {
        var config, queryType;
        config = _.isNull(data) ? {} : JSON.parse(data.configStr);
        queryType = req.params.id === 'home' ? 'getHomeTimeline' : 'getUserTimeline';
        return new TweetFetcher(req, res, queryType, null, config).fetchTweet();
      });
    });
  };

}).call(this);
