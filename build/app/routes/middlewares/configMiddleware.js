(function() {
  var ModelFactory, _, path;

  path = require('path');

  _ = require('lodash');

  ModelFactory = require(path.resolve('build', 'model', 'ModelFactory'));

  module.exports = {
    getConfig: function(req, res, next) {
      var opts;
      opts = {
        twitterIdStr: req.session.passport.user._json.id_str
      };
      return ModelFactory.create('config').findOneById(opts).then(function(data) {
        var config;
        config = _.isNull(data) ? {} : JSON.parse(data.configStr);
        req.config = config;
        return next();
      });
    }
  };

}).call(this);
