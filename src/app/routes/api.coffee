_                = require 'lodash'
path             = require 'path'
{my}             = require path.resolve 'build', 'lib', 'my'
{UserProvider}   = require path.resolve 'build', 'lib', 'model'

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
  (require './api/collect')(app)

  (require './api/users')(app)

  (require './api/friends')(app)

  (require './api/lists')(app)

  (require './api/favorites')(app)

  (require './api/statuses')(app)

  (require './api/timeline')(app)

  (require './api/config')(app)

  ###
  分類不明
  ###
  app.post '/api/download', (req, res) ->
    console.log "\n========> download, #{req.body.url}\n"
    my.loadBase64Data req.body.url
    .then (base64Data) ->
      console.log 'base64toBlob', base64Data.length
      res.json base64Data: base64Data

  app.post '/api/findUserById', (req, res) ->
    console.log "\n============> findUserById in API\n"
    UserProvider.findUserById
      twitterIdStr: req.session.passport.user._json.id_str
    , (err, data) ->
      res.json data: data
