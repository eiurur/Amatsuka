(function() {
  var TweetFetcher, TwitterClient, path;

  path = require('path');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  TweetFetcher = require(path.resolve('build', 'lib', 'TweetFetcher'));

  module.exports = function(app) {
    app.get('/api/favorites/lists/:id/:maxId?/:count?', function(req, res) {
      return new TweetFetcher(req, res, 'getFavLists', null, null).fetchTweet();
    });
    app.post('/api/favorites/create', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.createFav({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    return app.post('/api/favorites/destroy', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.destroyFav({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
  };

}).call(this);
