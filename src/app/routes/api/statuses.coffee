_             = require 'lodash'
path          = require 'path'
TwitterClient = require path.resolve 'build', 'lib', 'TwitterClient'
{settings}    = require path.resolve 'build', 'lib', 'configs', 'settings'

module.exports = (app) ->

  # ツイート情報を取得
  app.get '/api/statuses/show/:id', (req, res, next) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.showStatuses
      tweetIdStr: req.params.id
    .then (data) ->
      res.send data
    .catch (eerr) ->
      next err
    # .catch (error) ->
    #   res.status(429).send error

  # リツイート
  app.post '/api/statuses/retweet', (req, res, next) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.retweetStatus
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.send data
    .catch (eerr) ->
      next err
    # .catch (error) ->
    #   res.status(429).send error

  # リツイート解除
  app.post '/api/statuses/destroy', (req, res, next) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.destroyStatus
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.send data
    .catch (eerr) ->
      next err
    # .catch (error) ->
      # res.status(429).send error
