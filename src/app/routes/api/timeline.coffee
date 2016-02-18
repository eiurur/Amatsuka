_                = require 'lodash'
path             = require 'path'
TwitterClient    = require path.resolve 'build', 'lib', 'TwitterClient'
TweetFetcher     = require path.resolve 'build', 'lib', 'TweetFetcher'
{ConfigProvider} = require path.resolve 'build', 'lib', 'model'

module.exports = (app) ->

  # GET タイムラインの情報(home_timeline, user_timeline)
  app.get '/api/timeline/:id/:maxId?/:count?', (req, res) ->
    ConfigProvider.findOneById
      twitterIdStr: req.session.passport.user._json.id_str
    , (err, data) ->
      # 設定データが未登録
      config = if _.isNull data then {} else JSON.parse(data.configStr)
      queryType = if req.params.id is 'home'then 'getHomeTimeline' else 'getUserTimeline'
      new TweetFetcher(req, res, queryType, null, config).fetchTweet()