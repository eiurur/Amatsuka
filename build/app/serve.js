(function() {
  exports.serve = function() {
    var app, http, path, settings;
    http = require('http');
    path = require('path');
    settings = (process.env.NODE_ENV === 'production' ? require('../lib/configs/production') : require('../lib/configs/development')).settings;
    app = module.exports = (function() {
      var MongoStore, bodyParser, cookieParser, env, express, methodOverride, morgan, options, passport, session;
      express = require('express');
      bodyParser = require('body-parser');
      cookieParser = require('cookie-parser');
      methodOverride = require('method-override');
      morgan = require('morgan');
      passport = require('passport');
      session = require('express-session');
      MongoStore = require('connect-mongo')(session);
      options = {
        secret: settings.COOKIE_SECRET,
        saveUninitialized: true,
        resave: false,
        store: new MongoStore({
          url: process.env.MONGOHQ_URL || 'mongodb://127.0.0.1/aebs',
          collection: 'sessions',
          clear_interval: 3600 * 12,
          auto_reconnect: true
        })
      };
      app = express();
      app.set('port', process.env.PORT || 4321);
      app.set('views', __dirname + '/views');
      app.set('view engine', 'jade');
      app.use(morgan('dev'));
      app.use(cookieParser());
      app.use(bodyParser.json());
      app.use(bodyParser.urlencoded({
        extended: true
      }));
      app.use(methodOverride());
      app.use(session(options));
      app.use(passport.initialize());
      app.use(passport.session());
      app.use(express["static"](path.join(__dirname, 'public')));
      env = process.env.NODE_ENV || 'development';
      if (env === 'development') {
        app.locals.pretty = true;
        app.use(function(err, req, res, next) {
          res.status(err.status || 500);
          return res.render("error", {
            message: err.message,
            error: err
          });
        });
      }
      if (env === 'production') {
        app.locals.pretty = false;
      }
      console.log(settings);
      return app;
    })();
    (function() {
      var TwitterStrategy, UserProvider, passport;
      passport = require('passport');
      TwitterStrategy = require('passport-twitter').Strategy;
      UserProvider = require('../lib/model').UserProvider;
      passport.serializeUser(function(user, done) {
        done(null, user);
      });
      passport.deserializeUser(function(obj, done) {
        done(null, obj);
      });
      passport.use(new TwitterStrategy({
        consumerKey: settings.TW_CK,
        consumerSecret: settings.TW_CS,
        callbackURL: settings.CALLBACK_URL
      }, function(token, tokenSecret, profile, done) {
        console.log('User profile = ', profile);
        profile.twitter_token = token;
        profile.twitter_token_secret = tokenSecret;
        UserProvider.upsert({
          profile: profile
        }, function(err) {
          if (err) {
            console.log(err);
          }
          return done(null, profile);
        });
      }));
      app.get('/auth/twitter', passport.authenticate('twitter'));
      app.get('/auth/twitter/callback', passport.authenticate('twitter', {
        successRedirect: '/',
        failureRedirect: '/'
      }));
      return (require('./routes/routes'))(app);
    })();
    return (function() {
      var srv;
      return srv = app.listen(app.get('port'), function() {
        return console.log('Express server listening on port ' + app.get('port'));
      });
    })();
  };

}).call(this);
