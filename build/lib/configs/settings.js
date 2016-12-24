(function() {
  var path, settings;

  path = require('path');

  settings = (process.env.NODE_ENV === 'production' ? require(path.resolve('build', 'lib', 'configs', 'production')) : require(path.resolve('build', 'lib', 'configs', 'development'))).settings;

  console.log('settings ==> ', settings);

  exports.settings = settings;

}).call(this);
