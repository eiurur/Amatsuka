(function() {
  var TwitterClient, path;

  path = require('path');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  module.exports = function(app) {
    return app.get('/api/users/show/:id/:screenName?', function(req, res, next) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.showUsers({
        twitterIdStr: req.params.id,
        screenName: req.params.screenName
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(err) {
        return next(err);
      });
    });
  };

}).call(this);
