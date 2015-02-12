(function() {
  var Promise, UserProvider, dir, moment, my, settings, twitterTest, _;

  dir = '../../lib/';

  moment = require('moment');

  _ = require('lodash');

  Promise = require('es6-promise').Promise;

  my = require(dir + 'my');

  twitterTest = require(dir + 'twitter-test').twitterTest;

  UserProvider = require(dir + 'model').UserProvider;

  settings = process.env.NODE_ENV === 'production' ? require(dir + 'configs/production') : require(dir + 'configs/development');

  module.exports = function(app) {
    app.get('/logout', function(req, res) {
      if (!_.has(req.session, 'id')) {
        return;
      }
      req.logout();
      req.session.destroy();
      res.redirect("/");
    });
    app.get('/isAuthenticated', function(req, res) {
      var sessionUserData;
      sessionUserData = null;
      if (!_.isUndefined(req.session.passport.user)) {
        sessionUserData = req.session.passport.user;
      }
      res.json({
        data: sessionUserData
      });
    });
    app.get('/', function(req, res) {
      res.render("index");
    });
    app.get('/partials/:name', function(req, res) {
      var name;
      name = req.params.name;
      res.render("partials/" + name);
    });
    return app.get('*', function(req, res) {
      res.render("index");
    });
  };

}).call(this);
