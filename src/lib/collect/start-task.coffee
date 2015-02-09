_               = require 'lodash'
debug           = require 'debug'
{saveTweetData} = require './save-tweet-data'
{settings}      = if process.env.NODE_ENV is "production"
  require "../configs/production"
else
  require "../configs/development"

# HACK: collectフォルダの中にあるstartTaskだから、収集タスクを始めるんだなーってわかる。。。わかる？
# app.coffeeでは taskのなかのtaskStart？ハァ？だからあれだ。直そう。
exports.startTask = ->

  # HACK: これも命名がなー。settingsファイルの中だとtargetListが何のtargetなのかわからない。困る。
  # 収集対象者のscreenNameを取得
  targetList = settings.targetList

  # HACK: 命名がひどい。
  # Q. どんなメソッド？
  # A. 全員分のuser_timelineを3200件分取得するメソッドを実行するメソッドです。
  requestAllUserTimeline = ->
    target = targetList.pop()
    if _.isUndefined(target)
      clearInterval(requestAllUserTimeline)
      return
    console.log "======> #{target}"
    saveTweetData(target)

  # todo: 今は2秒間隔だけど本稼働させるときは 60秒間隔に変更
  setInterval requestAllUserTimeline, 2 * 1000
  requestAllUserTimeline()