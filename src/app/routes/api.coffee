dir              = '../../lib/'
moment           = require 'moment'
_                = require 'lodash'
{Promise}        = require 'es6-promise'
my               = require dir + 'my'
{twitterTest}    = require dir + 'twitter-test'
{UserProvider}   = require dir + 'model'
settings         = if process.env.NODE_ENV is 'production'
  require dir + 'configs/production'
else
  require dir + 'configs/development'

module.exports = (app) ->


  # JSON API
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

  # APIの動作テスト。後で消す
  app.post '/api/twitterTest', (req, res) ->
    console.log "\n============> twitterTest in API\n"
    console.log "req.body.user = ", req.body.user
    twitterTest(req.body.user)
    .then (data) ->
      console.log 'routes data = ', data
      res.json data: data

  #　まだ動かん
  app.get '/api/timeline/:type/:id', (req, res) ->
    console.log "\n============> get/timeline/:type/:id in API\n"
    PostProvider.findUserById
      twitterIdStr: req.params.id
    , (err, data) ->
      console.log data
      res.json data: data

  # GET リストの情報(公開、非公開)

  # GET リストのタイムラインを取得

  # GET タイムラインの情報(home_timeline, user_timeline)

  # GET アプリ上の仮想的なタイムラインの情報 ( = Amatsuka リスト)

  # GET フォロー状況の取得

  # POST フォロー、アンフォロー機能

  # POST 仮想フォロー、仮想アンフォロー機能( = Amatsukaリストへの追加、削除)

  #