path                   = require('path')
cronJob                = require('cron').CronJob
{cronTaskCollectPicts} = require path.resolve 'build', 'lib', 'cronTaskCollectPicts'
settings               = if process.env.NODE_ENV is 'production'
  require path.resolve 'build', 'lib', 'configs', 'production'
else
  require path.resolve 'build', 'lib', 'configs', 'development'

CRON_JOBS = [
  {
    time: '30 18 * * 4'
    # time: '*/1 * * * *'
    # time: '28 * * * *'
    job: cronTaskCollectPicts
  }
]

exports.manageCron = ->
  CRON_JOBS.forEach (item, index) ->
    console.log item
    job = new cronJob
      cronTime: item.time

      onTick: ->
        item.job.call()
        return

      onComplete: ->
        console.log 'Completed.'
        return

      start: true
      timeZone: 'Japan/Tokyo'