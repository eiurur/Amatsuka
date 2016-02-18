moment           = require 'moment'
_                = require 'lodash'
path             = require 'path'
chalk            = require 'chalk'
TwitterClient    = require path.resolve 'build', 'lib', 'TwitterClient'
TweetFetcher     = require path.resolve 'build', 'lib', 'TweetFetcher'
{my}             = require path.resolve 'build', 'lib', 'my'
{twitterUtils}   = require path.resolve 'build', 'lib', 'twitterUtils'
{UserProvider}   = require path.resolve 'build', 'lib', 'model'
{ConfigProvider} = require path.resolve 'build', 'lib', 'model'
settings         = if process.env.NODE_ENV is 'production'
  require path.resolve 'build', 'lib', 'configs', 'production'
else
  require path.resolve 'build', 'lib', 'configs', 'development'


# JSON API
module.exports = (app) ->

  ###
  Middleware
  ###
  app.use '/api/?', (req, res, next) ->
    console.log "======> #{req.originalUrl}"
    unless _.isUndefined(req.session.passport.user)
      next()
    else
      res.redirect '/'


  ###
  APIs
  ###
  (require './api/collect')(app)

  (require './api/lists')(app)

  (require './api/favorites')(app)

  (require './api/statuses')(app)

  (require './api/config')(app)


  ###
  APIs
  ###
  app.post '/api/download', (req, res) ->
    console.log "\n========> download, #{req.body.url}\n"
    my.loadBase64Data req.body.url
    .then (base64Data) ->
      console.log 'base64toBlob', base64Data.length
      res.json base64Data: base64Data

  ###
  Twitter
  ###
  app.post '/api/findUserById', (req, res) ->
    console.log "\n============> findUserById in API\n"
    UserProvider.findUserById
      twitterIdStr: req.session.passport.user._json.id_str
    , (err, data) ->
      res.json data: data

  # GET タイムラインの情報(home_timeline, user_timeline)
  app.get '/api/timeline/:id/:maxId?/:count?', (req, res) ->
    ConfigProvider.findOneById
      twitterIdStr: req.session.passport.user._json.id_str
    , (err, data) ->
      # 設定データが未登録
      config = if _.isNull data then {} else JSON.parse(data.configStr)
      queryType = if req.params.id is 'home'then 'getHomeTimeline' else 'getUserTimeline'
      new TweetFetcher(req, res, queryType, null, config).fetchTweet()


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


  # GET フォローイングの取得
  app.get '/api/friends/list/:id?/:cursor?/:count?', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.getFollowingList
      twitterIdStr: req.params.id
      cursor: req.params.cursor - 0
      count: req.params.count - 0
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

