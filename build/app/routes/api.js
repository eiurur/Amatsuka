(function() {
  module.exports = function(app) {
    (require('./middlewares/authMiddleware'))(app);
    (require('./api/collect'))(app);
    (require('./api/users'))(app);
    (require('./api/twitters'))(app);
    (require('./api/friends'))(app);
    (require('./api/lists'))(app);
    (require('./api/favorites'))(app);
    (require('./api/statuses'))(app);
    (require('./api/timeline'))(app);
    (require('./api/config'))(app);
    (require('./api/mao'))(app);
    return (require('./api/downloads'))(app);
  };

}).call(this);
