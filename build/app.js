(function() {
  var async, dir, moment, my, serve, settings, tasks4startUp, _;

  dir = './lib/';

  _ = require('lodash');

  moment = require('moment');

  async = require('async');

  my = require(dir + 'my').my;

  serve = require('./app/serve').serve;

  settings = (process.env.NODE_ENV === "production" ? require(dir + 'configs/production') : require(dir + 'configs/development')).settings;

  tasks4startUp = [
    function(callback) {
      my.c("■ Server task start");
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
