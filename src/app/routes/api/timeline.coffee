_                = require 'lodash'
path             = require 'path'
chalk            = require 'chalk'
TwitterClient    = require path.resolve 'build', 'lib', 'TwitterClient'
TweetFetcher     = require path.resolve 'build', 'lib', 'TweetFetcher'
{my}             = require path.resolve 'build', 'lib', 'my'
configMiddleware = require path.resolve 'build', 'app', 'routes', 'middlewares', 'configMiddleware'

module.exports = (app) ->

  # GET タイムラインの情報(home_timeline, user_timeline)
  app.get '/api/timeline/:id/:maxId?/:count?', configMiddleware.getConfig, (req, res) ->
    queryType = if req.params.id is 'home'then 'getHomeTimeline' else 'getUserTimeline'
    maxId = if _.isNaN(req.params.maxId - 0) then null else req.params.maxId - 0
    new TweetFetcher(req, res, queryType, maxId, req.config).fetchTweet()