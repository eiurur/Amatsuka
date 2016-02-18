_             = require 'lodash'
path          = require 'path'
TwitterClient = require path.resolve 'build', 'lib', 'TwitterClient'
settings      = if process.env.NODE_ENV is 'production'
  require path.resolve 'build', 'lib', 'configs', 'production'
else
  require path.resolve 'build', 'lib', 'configs', 'development'

module.exports = (app) ->

  # ツイート情報を取得
  app.get '/api/statuses/show/:id', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.showStatuses
      tweetIdStr: req.params.id
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

  # リツイート
  app.post '/api/statuses/retweet', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.retweetStatus
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

  # リツイート解除
  app.post '/api/statuses/destroy', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.destroyStatus
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error
