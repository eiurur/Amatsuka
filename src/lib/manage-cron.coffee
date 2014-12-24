_              = require 'lodash'
cronJob        = require('cron').CronJob
{UserProvider} = require './model'

# 毎日AM 2:00にタイムラインのユーザーを更新する
# @user: twitter.user
exports.resetTimeline = (user) ->

  # cronTime = "*/1 * * * *"
  # cronTime = "00 02 * * *"
  # job = new cronJob
  #   cronTime: cronTime
  #   onTick: ->
  #     console.log "Start ..."
  #     UserProvider.findAllUsers {}, (err, users) ->
  #       _.map users, (user) ->
  #         console.log 'map in user = ', user
  #         saveTL(user)

  #   onComplete: ->
  #     console.log "Completed."
  #     return

  #   start: true
  #   timeZone: "Japan/Tokyo"
