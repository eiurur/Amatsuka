(function() {
  var UserProvider, my, path, _;

  _ = require('lodash');

  path = require('path');

  my = require(path.resolve('build', 'lib', 'my')).my;

  UserProvider = require(path.resolve('build', 'lib', 'model')).UserProvider;

  module.exports = function(app) {

    /*
    Middleware
     */
    app.use('/api/?', function(req, res, next) {
      console.log("======> " + req.originalUrl);
      if (!_.isUndefined(req.session.passport.user)) {
        return next();
      } else {
        return res.redirect('/');
      }
    });

    /*
    APIs
     */
    (require('./api/collect'))(app);
    (require('./api/users'))(app);
    (require('./api/friends'))(app);
    (require('./api/lists'))(app);
    (require('./api/favorites'))(app);
    (require('./api/statuses'))(app);
    (require('./api/timeline'))(app);
    (require('./api/config'))(app);
    (require('./api/mao'))(app);

    /*
    分類不明
     */
    app.post('/api/download', function(req, res) {
      console.log("\n========> download, " + req.body.url + "\n");
      return my.loadBase64Data(req.body.url).then(function(base64Data) {
        console.log('base64toBlob', base64Data.length);
        return res.json({
          base64Data: base64Data
        });
      });
    });
    return app.post('/api/findUserById', function(req, res) {
      console.log("\n============> findUserById in API\n");
      return UserProvider.findUserById({
        twitterIdStr: req.session.passport.user._json.id_str
      }, function(err, data) {
        return res.json({
          data: data
        });
      });
    });
  };

}).call(this);
