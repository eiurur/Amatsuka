(function() {
  var ModelFactory, _, path, settings;

  _ = require('lodash');

  path = require('path');

  ModelFactory = require(path.resolve('build', 'model', 'ModelFactory'));

  settings = require(path.resolve('build', 'lib', 'configs', 'settings')).settings;

  module.exports = function(app) {
    app.get('/api/config', function(req, res) {
      var opts;
      opts = {
        twitterIdStr: req.session.passport.user._json.id_str
      };
      return ModelFactory.create('config').findOneById(opts).then(function(data) {
        return res.json({
          data: data
        });
      });
    });
    return app.post('/api/config', function(req, res) {
      var opts;
      opts = {
        twitterIdStr: req.session.passport.user._json.id_str,
        config: req.body.config
      };
      return ModelFactory.create('config').upsert(opts).then(function(data) {
        return res.json({
          data: data
        });
      });
    });
  };

}).call(this);
