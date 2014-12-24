(function() {
  var Promise, UserProvider, cron, dir, moment, my, settings, _;

  dir = '../../lib/';

  moment = require('moment');

  _ = require('lodash');

  Promise = require('es6-promise').Promise;

  my = require(dir + 'my');

  cron = require(dir + 'manage-cron');

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
    app.get('/', function(req, res) {
      res.render("index");
    });
    app.get('/partials/:name', function(req, res) {
      var name;
      name = req.params.name;
      res.render("partials/" + name);
    });
    app.get('/api/isAuthenticated', function(req, res) {
      var sessionUserData;
      sessionUserData = null;
      if (!_.isUndefined(req.session.passport.user)) {
        sessionUserData = req.session.passport.user;
      }
      return res.json({
        data: sessionUserData
      });
    });
    app.post('/api/findUserById', function(req, res) {
      console.log("\n============> findUserById in API\n");
      return UserProvider.findUserById({
        twitterIdStr: req.body.twitterIdStr
      }, function(err, data) {
        return res.json({
          data: data
        });
      });
    });
    return app.get('*', function(req, res) {
      res.render("index");
    });
  };

}).call(this);
