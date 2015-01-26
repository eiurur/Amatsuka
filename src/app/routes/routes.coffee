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
