(function() {
  var path, settings, _;

  _ = require('lodash');

  path = require('path');

  settings = process.env.NODE_ENV === 'production' ? require(path.resolve('build', 'lib', 'configs', 'production')) : require(path.resolve('build', 'lib', 'configs', 'development'));

  module.exports = function(app) {
    return app.get("" + settings.MAO_HOST + "/api/tweets", function(req, res) {
      console.log(req.session);
      console.log(settings.MAO_HOST);
      return TweetProvider.findByMaoTokenAndDate({
        maoToken: req.session.user.token,
        skip: req.query.skip - 0,
        limit: req.query.limit - 0,
        date: req.query.date
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(err) {
        return res.status(401).send(err);
      });
    });
  };

}).call(this);
