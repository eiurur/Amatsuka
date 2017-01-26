path             = require 'path'
TwitterClient    = require path.resolve 'build', 'lib', 'TwitterClient'

module.exports = (app) ->

  # GET フォローイングの取得
  app.get '/api/friends/list/:id?/:cursor?/:count?', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.getFollowingList
      twitterIdStr: req.params.id
      cursor: req.params.cursor - 0
      count: req.params.count - 0
    .then (data) ->
      res.send data
    .catch (error) ->
      res.status(420).send error
