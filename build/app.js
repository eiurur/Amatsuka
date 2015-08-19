(function() {
  var async, path, serve, settings, tasks4startUp;

  path = require('path');

  async = require('async');

  serve = require(path.resolve('build', 'app', 'serve')).serve;

  settings = process.env.NODE_ENV === 'production' ? require(path.resolve('build', 'lib', 'configs', 'production')) : require(path.resolve('build', 'lib', 'configs', 'development'));

  tasks4startUp = [
    function(callback) {
      console.log("■ Server task start");
      serve(null, "Create Server");
      setTimeout((function() {
        return callback(null, "Serve\n");
      }), settings.GRACE_TIME_SERVER);
    }
  ];

  async.series(tasks4startUp, function(err, results) {
    if (err) {
      console.error(err);
    } else {
      console.log("\nall done... Start!!!!\n");
    }
  });

}).call(this);
