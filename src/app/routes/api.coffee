moment           = require 'moment'
_                = require 'lodash'
path             = require 'path'
TwitterClient    = require path.resolve 'build', 'lib', 'TwitterClient'
PictCollection   = require path.resolve 'build', 'lib', 'PictCollection'
{my}             = require path.resolve 'build', 'lib', 'my'
{twitterUtils}   = require path.resolve 'build', 'lib', 'twitterUtils'
{UserProvider}   = require path.resolve 'build', 'lib', 'model'
{ConfigProvider} = require path.resolve 'build', 'lib', 'model'
{PictProvider}   = require path.resolve 'build', 'lib', 'model'
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
  app.post '/api/download', (req, res) ->
    console.log "\n========> download, #{req.body.url}\n"
    my.loadBase64Data req.body.url
    .then (base64Data) ->
      console.log 'base64toBlob', base64Data.length
      res.json base64Data: base64Data


  app.get '/api/collect/count', (req, res) ->
    PictProvider.count()
    .then (count) ->
      res.json count: count
    .catch (err) ->
      console.log err

  app.get '/api/collect/:skip?/:limit?', (req, res) ->
    PictProvider.find
      skip: req.params.skip - 0
      limit: req.params.limit - 0
    .then (data) ->
      res.send data

  app.post '/api/collect/profile', (req, res) ->
    pictCollection = new PictCollection(req.session.passport.user, req.body.twitterIdStr)

    # フォローしたユーザをデータベースに保存
    pictCollection.getIllustratorTwitterProfile()
    .then (data) -> pictCollection.setIllustratorRawData(data)
    .then -> pictCollection.getIllustratorRawData()
    .then (illustratorRawData) -> pictCollection.setUserTimelineMaxId(illustratorRawData.status.id_str)
    .then -> pictCollection.normalizeIllustratorData()
    .then -> pictCollection.updateIllustratorData()
    .then (data) -> pictCollection.setIllustratorDBData(data)
    .then (data) ->
      console.log 'End PictProvider.findOneAndUpdate data = ', data
      res.send data
    .catch (err) ->
      console.log err

  ###
  Twitter
  ###
  app.post '/api/findUserById', (req, res) ->
    console.log "\n============> findUserById in API\n"
    UserProvider.findUserById
      twitterIdStr: req.session.passport.user._json.id_str
    , (err, data) ->
      res.json data: data

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

  # GET リストのメンバー
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
  app.get '/api/lists/statuses/:id/:maxId?/:count?', (req, res) ->

    # HACK: 重複
    # memo: ConfigProvider.findOneByIdの実行「時間を計測したところ2msとかでした
    ConfigProvider.findOneById
      twitterIdStr: req.session.passport.user._json.id_str
    , (err, data) ->
      # 設定データが未登録
      config = if _.isNull data then {} else JSON.parse(data.configStr)
      console.log 'api lists config = ', config

      twitterClient = new TwitterClient(req.session.passport.user)
      twitterClient.getListsStatuses
        listIdStr: req.params.id
        maxId: req.params.maxId
        count: req.params.count
        includeRetweet: config.includeRetweet
      .then (tweets) ->
        console.log '/api/lists/list/:id/:count tweets.length = ', tweets.length
        tweetsNormalized = twitterUtils.normalizeTweets tweets, config
        res.json data: tweetsNormalized
      .catch (error) ->
        console.log '/api/lists/list/:id/:count error ', error
        res.json error: error

  # GET タイムラインの情報(home_timeline, user_timeline)
  app.get '/api/timeline/:id/:maxId?/:count?', (req, res) ->

    # HACK: 重複
    ConfigProvider.findOneById
      twitterIdStr: req.session.passport.user._json.id_str
    , (err, data) ->
      # 設定データが未登録
      config = if _.isNull data then {} else JSON.parse(data.configStr)
      m = if req.params.id is 'home'then 'getHomeTimeline' else 'getUserTimeline'
      twitterClient = new TwitterClient(req.session.passport.user)
      twitterClient[m]
        twitterIdStr: req.params.id
        maxId: req.params.maxId
        count: req.params.count
        includeRetweet: config.includeRetweet
      .then (tweets) ->
        console.log '/api/timeline/:id/:count tweets.length = ', tweets.length
        tweetsNormalized = twitterUtils.normalizeTweets tweets, config
        res.json data: tweetsNormalized
      .catch (error) ->
        res.json error: error

  # ツイート情報を取得
  app.get '/api/statuses/show/:id', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.showStatuses
      tweetIdStr: req.params.id
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

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



  # GET フォロー状況の取得

  # POST フォロー、アンフォロー機能

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


  ###
  Fav
  ###
  app.get '/api/favorites/lists/:id/:maxId?/:count?', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.getFavLists
      twitterIdStr: req.params.id
      maxId: req.params.maxId
      count: req.params.count
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

  app.post '/api/favorites/create', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.createFav
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

  app.post '/api/favorites/destroy', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.destroyFav
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error


  # POST リツイート、解除
  app.post '/api/statuses/retweet', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.retweetStatus
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

  app.post '/api/statuses/destroy', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.destroyStatus
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error


  ###
  # Config
  ###
  app.get '/api/config', (req, res) ->
    ConfigProvider.findOneById
      twitterIdStr: req.session.passport.user._json.id_str
    , (err, data) ->
      console.log 'get config: ', data
      res.json data: data

  app.post '/api/config', (req, res) ->
    console.log req.body
    ConfigProvider.upsert
      twitterIdStr: req.session.passport.user._json.id_str
      config: req.body.config
    , (err, data) ->
      console.log 'post config: ', data
      res.json data: data

