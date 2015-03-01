(function() {
  var async, dir, serve, settings, startTask, tasks4startUp;

  dir = './lib/';

  async = require('async');

  serve = require('./app/serve').serve;

  startTask = 　require("" + dir + "collect/start-task").startTask;

  settings = (process.env.NODE_ENV === "production" ? require("" + dir + "configs/production") : require("" + dir + "configs/development")).settings;

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
