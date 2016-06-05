(function() {
  var TwitterClient, path;

  path = require('path');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  module.exports = function(app) {
    app.get('/api/users/show/:id/:screenName?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.showUsers({
        twitterIdStr: req.params.id,
        screenName: req.params.screenName
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    return app.get('/api/twitter', function(req, res) {
      var twitterClient;
      console.log('/api/twitter', req.query);
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.getViaAPI({
        method: req.query.method,
        type: req.query.type,
        params: req.query
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
  };

}).call(this);
