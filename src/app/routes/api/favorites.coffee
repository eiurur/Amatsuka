_             = require 'lodash'
path          = require 'path'
TwitterClient = require path.resolve 'build', 'lib', 'TwitterClient'
TweetFetcher  = require path.resolve 'build', 'lib', 'TweetFetcher'
settings      = if process.env.NODE_ENV is 'production'
  require path.resolve 'build', 'lib', 'configs', 'production'
else
  require path.resolve 'build', 'lib', 'configs', 'development'

module.exports = (app) ->

  app.get '/api/favorites/lists/:id/:maxId?/:count?', (req, res) ->
    new TweetFetcher(req, res, 'getFavLists', null, null).fetchTweet()

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