(function() {
  var TwitterClient, _, path, settings;

  _ = require('lodash');

  path = require('path');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  settings = require(path.resolve('build', 'lib', 'configs', 'settings')).settings;

  module.exports = function(app) {
    app.get('/api/statuses/show/:id', function(req, res, next) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.showStatuses({
        tweetIdStr: req.params.id
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(eerr) {
        return next(err);
      });
    });
    app.post('/api/statuses/retweet', function(req, res, next) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.retweetStatus({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(eerr) {
        return next(err);
      });
    });
    return app.post('/api/statuses/destroy', function(req, res, next) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.destroyStatus({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(eerr) {
        return next(err);
      });
    });
  };

}).call(this);
