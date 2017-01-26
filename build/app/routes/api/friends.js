(function() {
  var TwitterClient, path;

  path = require('path');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  module.exports = function(app) {
    return app.get('/api/friends/list/:id?/:cursor?/:count?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.getFollowingList({
        twitterIdStr: req.params.id,
        cursor: req.params.cursor - 0,
        count: req.params.count - 0
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(error) {
        return res.status(429).send(error);
      });
    });
  };

}).call(this);
