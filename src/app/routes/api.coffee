moment                = require 'moment'
_                     = require 'lodash'
path                  = require 'path'
{my}                  = require path.resolve 'build', 'lib', 'my'
TwitterClient         = require path.resolve 'build', 'lib', 'TwitterClient'
{UserProvider}        = require path.resolve 'build', 'lib', 'model'
{ConfigProvider}      = require path.resolve 'build', 'lib', 'model'
{IllustratorProvider} = require path.resolve 'build', 'lib', 'model'
{PictProvider}        = require path.resolve 'build', 'lib', 'model'
settings              = if process.env.NODE_ENV is 'production'
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
    console.log "\n========> download\n"
    my.loadBase64Data req.body.url
    .then (base64Data) ->
      res.json base64Data: base64Data


  app.post '/api/collect', (req, res) ->
    console.log "\n========> Collect\n"
    userData = null
    maxId = null

    twitterClient = new TwitterClient(req.session.passport.user)

    twitterClient.showUsers
      twitterIdStr: req.body.twitterIdStr
    .then (data) ->

      maxId = data.status.id_str

      # TODO: 関数化
      return new Promise (resolve, reject) ->
        illustrator =
          twitterIdStr: data.id_str
          name: data.name
          screenName: data.screen_name
          icon: data.profile_image_url_https
          url: data.url
          description: data.description

        IllustratorProvider.findOneAndUpdate
          illustrator: illustrator
        , (err, data) ->
          return reject err  if err
          return resolve data
    .then (user) ->

      userData = user
      pictList = []

      isContinue = true

      my.promiseWhile((->
        # Condition for stopping
        isContinue
      ), ->
        # Action to run, should return a promise
        new Promise((resolve, reject) ->
          twitterClient.getUserTimeline
            twitterIdStr: user.twitterIdStr
            maxId: maxId
            count: '200'
            includeRetweet: false
          .then (data) ->
            # API制限くらったら return
            if _.isUndefined(data)
              isContinue = false
              reject()

            # 全部読み終えたら(残りがないとき、APIは最後のツイートだけ取得する === 1) return
            if data.length < 2
              isContinue = false
              resolve()

            maxId = data[data.length - 1].id_str


            # pictList = pictList.concat(tweetListIncludePict)
            tweetListIncludePict = _.chain(data)
            .filter (tweet) ->
              hasPict = _.has(tweet, 'extended_entities') and !_.isEmpty(tweet.extended_entities.media)
              hasPict
            .map (tweet) ->
              o = {}
              o.twitterIdStr = tweet.id_str
              o.totalNum = tweet.retweet_count + tweet.favorite_count
              o.mediaUrl = tweet.extended_entities.media[0].media_url_https
              o.mediaOrigUrl = tweet.extended_entities.media[0].media_url_https+':orig'
              o.displayUrl = tweet.extended_entities.media[0].display_url
              o.expandedUrl = tweet.extended_entities.media[0].expanded_url
              return o
            .value()

            pictList = pictList.concat(tweetListIncludePict)

            console.log 'pictList.length = ', pictList.length
            resolve()
          return
      )
      ).then (data) ->
        console.log 'Done'

        # pictListTop10 = _.chain(pictList).sortBy('totalNum').reverse().slice(0,10).value()
        pictListTop10 = _.chain(pictList)
        .sortBy('totalNum')
        .reverse()
        .slice(0,10)
        .value()

        console.log pictListTop10
        console.log pictListTop10.length

        return pictListTop10

    .then (data) ->
      console.log 'End getUserTimeline ', data.length
      PictProvider.findOneAndUpdate
        postedBy: userData._id
        pictTweetList: data
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
      .then (data) ->
        console.log '/api/lists/list/:id/:count data.length = ', data.length
        res.json data: data
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
      console.log 'api timeline config = ', config

      m = if req.params.id is 'home'then 'getHomeTimeline' else 'getUserTimeline'
      twitterClient = new TwitterClient(req.session.passport.user)
      twitterClient[m]
        twitterIdStr: req.params.id
        maxId: req.params.maxId
        count: req.params.count
        includeRetweet: config.includeRetweet
      .then (data) ->
        console.log '/api/timeline/:id/:count data.length = ', data.length
        res.json data: data
      .catch (error) ->
        res.json error: error

  # user情報を取得
  app.get '/api/users/show/:id', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.showUsers
      twitterIdStr: req.params.id
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

