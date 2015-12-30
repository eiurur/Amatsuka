(function() {
  var CRON_JOBS, cronJob, cronTaskCollectPicts, my, path, settings;

  path = require('path');

  cronJob = require('cron').CronJob;

  my = require('./my');

  cronTaskCollectPicts = require(path.resolve('build', 'lib', 'cronTaskCollectPicts')).cronTaskCollectPicts;

  settings = process.env.NODE_ENV === 'production' ? require(path.resolve('build', 'lib', 'configs', 'production')) : require(path.resolve('build', 'lib', 'configs', 'development'));

  CRON_JOBS = [
    {
      time: '*/1 * * * *',
      job: cronTaskCollectPicts
    }
  ];

  exports.manageCron = function() {
    var job;
    job = void 0;
    CRON_JOBS.forEach(function(item, index) {
      console.log(item);
      job = new cronJob({
        cronTime: item.time,
        onTick: function() {
          item.job.call();
        },
        onComplete: function() {
          console.log('Completed.');
        },
        start: true,
        timeZone: 'Japan/Tokyo'
      });
    });
  };

  return;

}).call(this);
