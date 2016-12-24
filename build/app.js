(function() {
  var async, manageCron, path, serve, settings, tasks4startUp;

  path = require('path');

  async = require('async');

  serve = require(path.resolve('build', 'app', 'serve')).serve;

  manageCron = require(path.resolve('build', 'lib', 'manageCron')).manageCron;

  settings = require(path.resolve('build', 'lib', 'configs', 'settings')).settings;

  tasks4startUp = [
    function(callback) {
      console.log("■ Server task start");
      serve(null, "Create Server");
      setTimeout((function() {
        return callback(null, "Serve\n");
      }), settings.GRACE_TIME_SERVER);
    }, function(callback) {
      console.log("■ collect profile and picts task start");
      manageCron(null, "setup cron");
      setTimeout((function() {
        return callback(null, "Done! collect task\n");
      }), 0);
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
