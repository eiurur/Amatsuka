_             = require 'lodash'
{Promise}     = require 'es6-promise'
{my}          = require './my'
{TLProvider}  = require './model'
TwitterCilent = require './TwitterClient'
{settings}    = if process.env.NODE_ENV is "production"
  require './configs/production'
else
  require './configs/development'

exports.twitterPostTest = (user) ->

  TARGET_TWITTER_ID_STR = '2686409167'
  TARGET_TWEET_ID_STR = '535402680378597377'
  retweetIdStr = '' # テスト用

  twitterClient = new TwitterCilent(user)

  return new Promise (resolve, reject) ->
    twitterClient.retweetStatus(tweetIdStr: TARGET_TWEET_ID_STR)
    .then (data) ->
      console.log '\nretweetStatus -> ', data.retweeted_status.id_str

      # テスト用
      retweetIdStr = data.id_str
      console.log retweetIdStr

      twitterClient.createFav(tweetIdStr: data.retweeted_status.id_str)
    .then (data) ->
      console.log '\n createFav -> ', data
      console.log retweetIdStr

      twitterClient.destroyFav(tweetIdStr: retweetIdStr)
    .then (data) ->
      console.log "\n destroyFav ->  #{data.id_str} , #{data.text}"

      twitterClient.destroyStatus(tweetIdStr: data.id_str)
    .then (data) ->
      console.log "\n getListsCreate ->  #{data.id_str} , #{data.text}"

      twitterClient.getFavList(twitterIdStr: TARGET_TWITTER_ID_STR)
    .then (data) ->
      # console.log data.length
      # latestTweet =
      # console.log latestTweet
      latestFavIdStr = data[0].id_str
      console.log '\n getFavList latestFavIdStr -> ', latestFavIdStr

      return resolve data

    .catch (err) ->
      console.log 'twitter tweet test err =======> ', err
      return reject err
