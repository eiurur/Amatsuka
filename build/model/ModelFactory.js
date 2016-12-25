(function() {
  var ConfigProvider, IllustratorProvider, ModelFactory, PictProvider, UserProvider, cp, ip, path, pp, up;

  path = require('path');

  ConfigProvider = require(path.resolve('build', 'model', 'ConfigProvider'));

  IllustratorProvider = require(path.resolve('build', 'model', 'IllustratorProvider'));

  PictProvider = require(path.resolve('build', 'model', 'PictProvider'));

  UserProvider = require(path.resolve('build', 'model', 'UserProvider'));

  cp = new ConfigProvider();

  ip = new IllustratorProvider();

  pp = new PictProvider();

  up = new UserProvider();

  module.exports = ModelFactory = (function() {
    function ModelFactory() {}

    ModelFactory.create = function(name) {
      switch (name.toLowerCase()) {
        case 'config':
          return cp;
        case 'illustrator':
          return ip;
        case 'pict':
          return pp;
        case 'user':
          return up;
        default:
          return null;
      }
    };

    return ModelFactory;

  })();

}).call(this);
