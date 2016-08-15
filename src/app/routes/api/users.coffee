path             = require 'path'
TwitterClient    = require path.resolve 'build', 'lib', 'TwitterClient'

module.exports = (app) ->

  # user情報を取得
  app.get '/api/users/show/:id/:screenName?', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.showUsers
      twitterIdStr: req.params.id
      screenName: req.params.screenName
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

  # TODO: 別ファイル化
  # 汎用化したver
  app.get '/api/twitter', (req, res) ->
    console.log 'GET /api/twitter', req.query
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.getViaAPI method: req.query.method, type: req.query.type, params: req.query
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

  app.post '/api/twitter', (req, res) ->
    console.log 'POST /api/twitter', req.body
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.postViaAPI method: req.body.method, type: req.body.type, params: req.body
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error