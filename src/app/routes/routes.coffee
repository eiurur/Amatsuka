dir              = '../../lib/'
moment           = require 'moment'
_                = require 'lodash'
{Promise}        = require 'es6-promise'
my               = require dir + 'my'
{twitterTest}    = require dir + 'twitter-test'
{UserProvider}   = require dir + 'model'
settings         = if process.env.NODE_ENV is 'production'
  require dir + 'configs/production'
else
  require dir + 'configs/development'

module.exports = (app) ->

  app.get '/logout', (req, res) ->
    return  unless _.has(req.session, 'id')
    req.logout()
    req.session.destroy()
    res.redirect "/"
    return

  app.get '/isAuthenticated', (req, res) ->
    sessionUserData = null
    unless _.isUndefined req.session.passport.user
      sessionUserData = req.session.passport.user
    res.json data: sessionUserData
    return

  # serve index and view partials
  app.get '/', (req, res) ->
    res.render "index"
    return

  app.get '/partials/:name', (req, res) ->
    name = req.params.name
    res.render "partials/" + name
    return

  # redirect all others to the index (HTML5 history)
  app.get '*', (req, res) ->
    res.render "index"
    return
