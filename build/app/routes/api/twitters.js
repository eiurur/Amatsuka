(function() {
  var TwitterClient, path;

  path = require('path');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  module.exports = function(app) {
    app.get('/api/twitter', function(req, res) {
      var twitterClient;
      console.log('GET /api/twitter', req.query);
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.getViaAPI({
        method: req.query.method,
        type: req.query.type,
        params: req.query
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(error) {
        return res.status(429).send(error);
      });
    });
    return app.post('/api/twitter', function(req, res) {
      var twitterClient;
      console.log('POST /api/twitter', req.body);
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.postViaAPI({
        method: req.body.method,
        type: req.body.type,
        params: req.body
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(error) {
        return res.status(429).send(error);
      });
    });
  };

}).call(this);
