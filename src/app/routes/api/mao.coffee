_                = require 'lodash'
axios            = require 'axios'
path             = require 'path'
{twitterUtils}   = require path.resolve 'build', 'lib', 'twitterUtils'
{ConfigProvider} = require path.resolve 'build', 'lib', 'model'
{my}             = require path.resolve 'build', 'lib', 'my'
{settings}       = if process.env.NODE_ENV is 'production'
  require path.resolve 'build', 'lib', 'configs', 'production'
else
  require path.resolve 'build', 'lib', 'configs', 'development'

module.exports = (app) ->

  app.get "/api/mao", (req, res) ->
    _config = null
    ConfigProvider.findOneById
      twitterIdStr: req.session.passport.user._json.id_str
    , (err, data) ->

      # 設定データが未登録
      _config = if _.isNull data then {} else JSON.parse(data.configStr)

      axios.get "#{settings.MAO_HOST}/api/tweets",
        params:
          maoToken: my.createHash(req.session.passport.user._json.id_str + settings.MAO_TOKEN_SALT)
          skip: req.query.skip - 0
          limit: req.query.limit - 0
          date: req.query.date
      .then (response) ->
        console.log response.data.length
        console.log response.status
        unless response.status is 200 then new throw Error('Not Authorized')
        tweets = twitterUtils.normalizeTweets(response.data, _config)
        res.send tweets
      .catch (err) ->
        console.error err
        res.status(401).send(err)

  app.get "/api/mao/stats/tweet/count", (req, res) ->
    axios.get "#{settings.MAO_HOST}/api/stats/tweet/count",
      params:
        maoToken: my.createHash(req.session.passport.user._json.id_str + settings.MAO_TOKEN_SALT)
        skip: req.query.skip - 0
        limit: req.query.limit - 0
        # date: req.query.date
    .then (response) ->
      console.log response.data.length
      console.log response.status
      unless response.status is 200 then new throw Error('Not Authorized')
      # tweets = twitterUtils.normalizeTweets(response.data, _config)
      res.send response.data
    .catch (err) ->
      console.error err
      res.status(401).send(err)