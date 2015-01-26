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
    app.post('/api/twitterTest', function(req, res) {
      console.log("\n============> twitterTest in API\n");
      console.log("req.body.user = ", req.body.user);
      return twitterTest(req.body.user).then(function(data) {
        console.log('routes data = ', data);
        return res.json({
          data: data
        });
      });
    });
    return app.get('/api/timeline/:type/:id', function(req, res) {
      console.log("\n============> get/timeline/:type/:id in API\n");
      return PostProvider.findUserById({
        twitterIdStr: req.params.id
      }, function(err, data) {
        console.log(data);
        return res.json({
          data: data
        });
      });
    });
  };

}).call(this);
