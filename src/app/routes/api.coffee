dir               = '../../lib/'
moment            = require 'moment'
_                 = require 'lodash'
{Promise}         = require 'es6-promise'
my                = require "#{dir}my"
TwitterCilent     = require "#{dir}TwitterClient"
{twitterTest}     = require "#{dir}twitter-test"
{twitterPostTest} = require "#{dir}twitter-post-test"
{UserProvider}    = require "#{dir}model"
settings          = if process.env.NODE_ENV is 'production'
  require dir + 'configs/production'
else
  require dir + 'configs/development'


# JSON API
module.exports = (app) ->

  app.get '/api/isAuthenticated', (req, res) ->
    sessionUserData = null
    unless _.isUndefined req.session.passport.user
      sessionUserData = req.session.passport.user
    res.json data: sessionUserData

  app.post '/api/findUserById', (req, res) ->
    console.log "\n============> findUserById in API\n"
    UserProvider.findUserById
      twitterIdStr: req.body.twitterIdStr
    , (err, data) ->
      res.json data: data

  # ここから下のにだけ適用。
  # todo? hack?
  # /api/twitter/~ にするか、
  # ログインが不要なリクエストから /api を省くか、
  # どっちかにしたほうが見通しがいい。
  # 修正して
  app.use '/api/?', (req, res, next) ->
    console.log "======> #{req.originalUrl}"
    unless _.isUndefined(req.session.passport.user)
      next()
    else
      res.redirect '/'

  # APIの動作テスト。後で消す
  app.post '/api/twitterTest', (req, res) ->
    twitterTest(req.body.user)
    .then (data) ->
      console.log 'twitterTest data = ', data
      res.json data: data

  # APIの動作テスト(おもに投稿関連)。後で消す
  app.post '/api/twitterPostTest', (req, res) ->
    twitterPostTest(req.body.user)
    .then (data) ->
      # console.log 'twitterPostTest data = ', data
      res.json data: data

  # GET リストの情報(公開、非公開)
  app.get '/api/lists/list/:id?/:count?', (req, res) ->
    twitterClient = new TwitterCilent(req.session.passport.user)
    twitterClient.getListsList
      twitterIdStr: req.params.id
      count: req.params.count
    .then (data) ->
      console.log '/api/lists/list/:id/:count data.length = ', data.length
      res.json data: data

  # POST リストの作成
  app.post '/api/lists/create', (req, res) ->
    twitterClient = new TwitterCilent(req.session.passport.user)
    twitterClient.createLists
      name: req.body.name
      mode: req.body.mode
    .then (data) ->
      console.log '/api/lists/create', data.length
      res.json data: data

  # GET リストのメンバー
  app.get '/api/lists/members/:id?/:count?', (req, res) ->
    twitterClient = new TwitterCilent(req.session.passport.user)
    twitterClient.getListsMembers
      listIdStr: req.params.id
      count: req.params.count
    .then (data) ->
      console.log '/api/lists/members/:id/:count data.length = ', data.length
      res.json data: data

  # GET リストのタイムラインを取得
  app.get '/api/lists/statuses/:id/:maxId?/:count?', (req, res) ->
    twitterClient = new TwitterCilent(req.session.passport.user)
    twitterClient.getListsStatuses
      listIdStr: req.params.id
      maxId: req.params.maxId
      count: req.params.count
    .then (data) ->
      console.log '/api/lists/list/:id/:count data.length = ', data.length
      res.json data: data

  # GET タイムラインの情報(home_timeline, user_timeline)
  app.get '/api/timeline/:id/:maxId?/:count?', (req, res) ->
    m = if req.params.id is 'home'then 'getHomeTimeline' else 'getUserTimeline'
    twitterClient = new TwitterCilent(req.session.passport.user)
    twitterClient[m]
      listIdStr: req.params.id
      maxId: req.params.maxId
      count: req.params.count
    .then (data) ->
      console.log '/api/timeline/list/:id/:count data.length = ', data.length
      res.json data: data

  # GET アプリ上の仮想的なタイムラインの情報 ( = Amatsuka リスト)
  # まず、Amatsukaリストの存在を確認
  # あれば、それを返すだけ。


  # GET フォロー状況の取得

  # POST フォロー、アンフォロー機能

  # POST 仮想フォロー、仮想アンフォロー機能( = Amatsukaリストへの追加、削除)
  app.post '/api/lists/members/create', (req, res) ->
    twitterClient = new TwitterCilent(req.session.passport.user)
    twitterClient.createListsMembers
      listIdStr: req.body.listIdStr
      twitterIdStr: req.body.twitterIdStr
    .then (data) ->
      res.json data: data

  app.post '/api/lists/members/destroy', (req, res) ->
    twitterClient = new TwitterCilent(req.session.passport.user)
    twitterClient.destroyListsMembers
      listIdStr: req.body.listIdStr
      twitterIdStr: req.body.twitterIdStr
    .then (data) ->
      res.json data: data


  # POST ふぁぼ、あんふぁぼ
  app.post '/api/favorites/create', (req, res) ->
    twitterClient = new TwitterCilent(req.session.passport.user)
    twitterClient.createFav
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.json data: data

  app.post '/api/favorites/destroy', (req, res) ->
    twitterClient = new TwitterCilent(req.session.passport.user)
    twitterClient.destroyFav
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.json data: data


  # POST リツイート、解除
  app.post '/api/statuses/retweet', (req, res) ->
    twitterClient = new TwitterCilent(req.session.passport.user)
    twitterClient.retweetStatus
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.json data: data

  app.post '/api/statuses/destroy', (req, res) ->
    twitterClient = new TwitterCilent(req.session.passport.user)
    twitterClient.destroyStatus
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.json data: data