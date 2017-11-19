(function() {
  var CRON_JOBS, cronJob, cronTaskCollectPicts, path;

  path = require('path');

  cronJob = require('cron').CronJob;

  cronTaskCollectPicts = require(path.resolve('build', 'lib', 'cronTaskCollectPicts')).cronTaskCollectPicts;

  CRON_JOBS = [
    {
      time: '44 15 * * *',
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
        timeZone: 'Asia/Tokyo'
      });
    });
  };

}).call(this);
