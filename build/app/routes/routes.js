(function() {
  var UserProvider, _, moment, my, path, settings;

  path = require('path');

  moment = require('moment');

  _ = require('lodash');

  my = require(path.resolve('build', 'lib', 'my')).my;

  UserProvider = require(path.resolve('build', 'lib', 'model')).UserProvider;

  settings = process.env.NODE_ENV === 'production' ? require(path.resolve('build', 'lib', 'configs', 'production')) : require(path.resolve('build', 'lib', 'configs', 'development'));

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
