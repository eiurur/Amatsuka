_                = require 'lodash'
path             = require 'path'
{ConfigProvider} = require path.resolve 'build', 'lib', 'model'
settings         = if process.env.NODE_ENV is 'production'
  require path.resolve 'build', 'lib', 'configs', 'production'
else
  require path.resolve 'build', 'lib', 'configs', 'development'

module.exports = (app) ->

  app.get '/api/config', (req, res) ->
    ConfigProvider.findOneById
      twitterIdStr: req.session.passport.user._json.id_str
    , (err, data) ->
      # console.log 'get config: ', data
      res.json data: data

  app.post '/api/config', (req, res) ->
    # console.log req.body
    ConfigProvider.upsert
      twitterIdStr: req.session.passport.user._json.id_str
      config: req.body.config
    , (err, data) ->
      # console.log 'post config: ', data
      res.json data: data
