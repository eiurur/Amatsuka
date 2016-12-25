(function() {
  module.exports = function(app) {
    return app.use('/api/?', function(req, res, next) {
      console.log("(@^^)/~~~ ======> " + req.originalUrl);
      if (typeof req.session.passport.user !== "undefined") {
        return next();
      } else {
        console.log('(#^.^#) invalid');
        return res.redirect('/');
      }
    });
  };

}).call(this);
