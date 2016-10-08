(function() {
  var CRON_JOBS, cronJob, cronTaskCollectPicts, path, settings;

  path = require('path');

  cronJob = require('cron').CronJob;

  cronTaskCollectPicts = require(path.resolve('build', 'lib', 'cronTaskCollectPicts')).cronTaskCollectPicts;

  settings = process.env.NODE_ENV === 'production' ? require(path.resolve('build', 'lib', 'configs', 'production')) : require(path.resolve('build', 'lib', 'configs', 'development'));

  CRON_JOBS = [
    {
      time: '10 0 2,9 * *',
      job: cronTaskCollectPicts
    }
  ];

  exports.manageCron = function() {
    return CRON_JOBS.forEach(function(item, index) {
      var job;
      console.log(item);
      return job = new cronJob({
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

}).call(this);
