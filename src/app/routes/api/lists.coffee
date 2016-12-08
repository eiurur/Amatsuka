_                = require 'lodash'
path             = require 'path'
chalk            = require 'chalk'
TwitterClient    = require path.resolve 'build', 'lib', 'TwitterClient'
TweetFetcher     = require path.resolve 'build', 'lib', 'TweetFetcher'
{my}             = require path.resolve 'build', 'lib', 'my'
{ConfigProvider} = require path.resolve 'build', 'lib', 'model'
settings         = if process.env.NODE_ENV is 'production'
  require path.resolve 'build', 'lib', 'configs', 'production'
else
  require path.resolve 'build', 'lib', 'configs', 'development'

module.exports = (app) ->

  # GET リストの情報(公開、非公開)
  app.get '/api/lists/list/:id?/:count?', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.getListsList
      twitterIdStr: req.params.id
      count: req.params.count
    .then (data) ->
      console.log '/api/lists/list/:id/:count data.length = ', data.length
      res.json data: data
    .catch (error) ->
      console.log '/api/lists/list/:id/:count error = ', error
      res.json error: error

  # POST リストの作成
  app.post '/api/lists/create', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.createLists
      name: req.body.name
      mode: req.body.mode
    .then (data) ->
      console.log '/api/lists/create', data.length
      res.json data: data
    .catch (error) ->
      res.json error: error

  # GET リストのメンバー(statusとentitesは除外する)
  app.get '/api/lists/members/:id?/:count?', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.getListsMembers
      listIdStr: req.params.id
      count: req.params.count
    .then (data) ->
      console.log '/api/lists/members/:id/:count data.length = ', data.length
      res.json data: data
    .catch (error) ->
      res.json error: error


  # GET リストのタイムラインを取得
  # memo: ConfigProvider.findOneByIdの実行「時間を計測したところ2msとかでした
  app.get '/api/lists/statuses/:id/:maxId?/:count?', (req, res) ->
    ConfigProvider.findOneById
      twitterIdStr: req.session.passport.user._json.id_str
    , (err, data) ->
      # 設定データが未登録
      config = if _.isNull data then {} else JSON.parse(data.configStr)
      new TweetFetcher(req, res, 'getListsStatuses', null, config).fetchTweet()

  # POST 仮想フォロー、仮想アンフォロー機能( = Amatsukaリストへの追加、削除)
  app.post '/api/lists/members/create', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.createListsMembers
      listIdStr: req.body.listIdStr
      twitterIdStr: req.body.twitterIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

  app.post '/api/lists/members/create_all', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.createAllListsMembers
      listIdStr: req.body.listIdStr
      twitterIdStr: req.body.twitterIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

  app.post '/api/lists/members/destroy', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.destroyListsMembers
      listIdStr: req.body.listIdStr
      twitterIdStr: req.body.twitterIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error



