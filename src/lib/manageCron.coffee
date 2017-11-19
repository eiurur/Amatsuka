path                   = require('path')
cronJob                = require('cron').CronJob
{cronTaskCollectPicts} = require path.resolve 'build', 'lib', 'cronTaskCollectPicts'

CRON_JOBS = [
  {
    time: '10 0 10,20 * *'
    # time: '44 15 * * *'
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
      timeZone: 'Asia/Tokyo'