axios            = require 'axios'
path             = require 'path'
{twitterUtils}   = require path.resolve 'build', 'lib', 'twitterUtils'
{my}             = require path.resolve 'build', 'lib', 'my'
{settings}       = require path.resolve 'build', 'lib', 'configs', 'settings'
configMiddleware = require path.resolve 'build', 'app', 'routes', 'middlewares', 'configMiddleware'


module.exports = (app) ->

  app.get "/api/mao", configMiddleware.getConfig, (req, res) ->
    axios.get "#{settings.MAO_HOST}/api/tweets",
      params:
        maoToken: my.createHash(req.session.passport.user._json.id_str + settings.MAO_TOKEN_SALT)
        skip: req.query.skip - 0
        limit: req.query.limit - 0
        date: req.query.date
    .then (response) ->
      unless response.status is 200 then new throw Error('Not Authorized')
      tweets = twitterUtils.normalizeTweets(response.data, req.config)
      res.send tweets
    .catch (err) ->
      console.error err
      res.status(401).send(err)

  app.get "/api/mao/tweets/count", (req, res) ->
    axios.get "#{settings.MAO_HOST}/api/tweets/count",
      params:
        maoToken: my.createHash(req.session.passport.user._json.id_str + settings.MAO_TOKEN_SALT)
        date: req.query.date
    .then (response) ->
      unless response.status is 200 then new throw Error('Not Authorized')
      res.send response.data
    .catch (err) ->
      console.error '/api/mao/tweets/count err ', err
      res.status(401).send(err)

  app.get "/api/mao/stats/tweet/count", (req, res) ->
    axios.get "#{settings.MAO_HOST}/api/stats/tweet/count",
      params:
        maoToken: my.createHash(req.session.passport.user._json.id_str + settings.MAO_TOKEN_SALT)
        skip: req.query.skip - 0
        limit: req.query.limit - 0
    .then (response) ->
      unless response.status is 200 then new throw Error('Not Authorized')
      res.send response.data
    .catch (err) ->
      console.error '/api/mao/stats/tweets/count err ', err
      res.status(401).send(err)