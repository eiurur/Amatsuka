path             = require 'path'
TwitterClient    = require path.resolve 'build', 'lib', 'TwitterClient'

module.exports = (app) ->

  # user情報を取得
  app.get '/api/users/show/:id/:screenName?', (req, res, next) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.showUsers
      twitterIdStr: req.params.id
      screenName: req.params.screenName
    .then (data) ->
      res.send data
    .catch (eerr) ->
      next err
    # .catch (error) ->
    #   res.status(429).send error
