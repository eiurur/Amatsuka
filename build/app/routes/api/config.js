(function() {
  var ConfigProvider, path, settings, _;

  _ = require('lodash');

  path = require('path');

  ConfigProvider = require(path.resolve('build', 'lib', 'model')).ConfigProvider;

  settings = process.env.NODE_ENV === 'production' ? require(path.resolve('build', 'lib', 'configs', 'production')) : require(path.resolve('build', 'lib', 'configs', 'development'));

  module.exports = function(app) {
    app.get('/api/config', function(req, res) {
      return ConfigProvider.findOneById({
        twitterIdStr: req.session.passport.user._json.id_str
      }, function(err, data) {
        console.log('get config: ', data);
        return res.json({
          data: data
        });
      });
    });
    return app.post('/api/config', function(req, res) {
      console.log(req.body);
      return ConfigProvider.upsert({
        twitterIdStr: req.session.passport.user._json.id_str,
        config: req.body.config
      }, function(err, data) {
        console.log('post config: ', data);
        return res.json({
          data: data
        });
      });
    });
  };

}).call(this);
