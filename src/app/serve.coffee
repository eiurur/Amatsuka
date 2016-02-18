exports.serve = ->

  http       = require 'http'
  path       = require 'path'
  {settings} = if process.env.NODE_ENV is 'production'
    require('../lib/configs/production')
  else
    require('../lib/configs/development')

  app = module.exports = do -> # application

    express        = require 'express'
    bodyParser     = require 'body-parser'
    cookieParser   = require 'cookie-parser'
    methodOverride = require 'method-override'
    morgan         = require 'morgan'
    passport       = require 'passport'
    session        = require 'express-session'
    compression    = require 'compression'
    MongoStore     = require('connect-mongo')(session)

    options =
      secret: settings.COOKIE_SECRET
      saveUninitialized: true
      resave: false
      store: new MongoStore(
        url: process.env.MONGOHQ_URL or 'mongodb://127.0.0.1/amatsuka'
        collection: 'sessions'
        clear_interval: 3600 * 12
        auto_reconnect: true
      )

    cacheOptions =
      dotfiles: 'ignore'
      etag: false
      extensions: [
        'htm'
        'html'
        'css'
        'js'
        'jpg'
        'png'
        'gif'
        'mp4'
      ]
      index: false
      maxAge: 0
      redirect: false
      setHeaders: (res, path, stat) ->
        res.set 'x-timestamp': Date.now()
        return

    app = express()
    app.disable 'x-powered-by'
    app.set 'port', process.env.PORT or settings.PORT
    app.set 'views', __dirname + '/views'
    app.set 'view engine', 'jade'
    app.use morgan('dev')
    app.use cookieParser()
    app.use bodyParser.json(limit: '50mb')
    app.use bodyParser.urlencoded(extended: true, limit: '50mb')
    app.use methodOverride()
    app.use session(options)
    app.use compression()
    app.use passport.initialize()
    app.use passport.session()
    app.use express.static(path.join(__dirname, 'public'), cacheOptions)

    env = process.env.NODE_ENV or 'development'

    # development only
    if env is 'development'
      fs = require('fs')
      stream = fs.createWriteStream(__dirname + '/log.txt', flags: 'a')
      # app.use morgan(stream: stream)

      app.locals.pretty = true
      app.use (err, req, res, next) ->
        res.status err.status or 500
        res.render "error",
          message: err.message
          error: err

    # production only
    app.locals.pretty = false  if env is 'production'

    console.log settings

    return app


  do -> # routes, session

    passport        = require 'passport'
    TwitterStrategy = require('passport-twitter').Strategy
    {UserProvider}  = require '../lib/model'

    passport.serializeUser (user, done) ->
      done null, user
      return

    passport.deserializeUser (obj, done) ->
      done null, obj
      return

    passport.use new TwitterStrategy
      consumerKey: settings.TW_CK
      consumerSecret: settings.TW_CS
      callbackURL: settings.CALLBACK_URL
    , (token, tokenSecret, profile, done) ->
      console.log 'User profile = ', profile
      profile.twitter_token = token
      profile.twitter_token_secret = tokenSecret

      user =
        twitterIdStr: profile._json.id_str
        name: profile.username
        screenName: profile.displayName
        icon: profile._json.profile_image_url_https
        url: profile._json.url
        accessToken: token
        accessTokenSecret: tokenSecret

      UserProvider.findOneAndUpdate
        user: user
      , (err, data) ->
        console.log err  if err
        done null, profile
      return

    app.get '/auth/twitter', passport.authenticate('twitter')

    app.get '/auth/twitter/callback', passport.authenticate 'twitter',
      successRedirect: '/'
      failureRedirect: '/'

    (require './routes/api')(app)
    (require './routes/routes')(app)


  do -> #server
    # http.createServer(app).listen app.get("port"), ->
    #   console.log "Express server listening on port " + app.get("port")

    srv = app.listen app.get('port'), ->
      console.log 'Express server listening on port ' + app.get('port')
