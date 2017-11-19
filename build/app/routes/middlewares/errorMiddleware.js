(function() {
  module.exports = function(app) {
    return app.use(function(err, req, res, next) {
      res.status(err.status || 500);
      return res.send(err);
    });
  };

}).call(this);
