(function() {
  module.exports = function(app) {
    app.get('/logout', function(req, res) {
      var ref;
      if (((ref = req.session) != null ? ref.id : void 0) == null) {
        return;
      }
      req.logout();
      req.session.destroy();
      res.redirect("/");
    });
    app.get('/isAuthenticated', function(req, res) {
      var sessionUserData;
      sessionUserData = null;
      if (typeof req.session.passport.user !== "undefined") {
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
