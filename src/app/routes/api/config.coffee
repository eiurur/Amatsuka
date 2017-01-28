path         = require 'path'
ModelFactory = require path.resolve 'build', 'model', 'ModelFactory'

module.exports = (app) ->

  app.get '/api/config', (req, res) ->
    opts = twitterIdStr: req.session.passport.user._json.id_str
    ModelFactory.create('config').findOneById opts
    .then (data) ->
      res.send data

  app.post '/api/config', (req, res) ->
    opts =
      twitterIdStr: req.session.passport.user._json.id_str
      config: req.body.config
    ModelFactory.create('config').upsert opts
    .then (data) ->
      res.send data
