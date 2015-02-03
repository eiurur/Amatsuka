(function() {
  var Promise, TwitterCilent, UserProvider, dir, moment, my, settings, twitterPostTest, twitterTest, _;

  dir = '../../lib/';

  moment = require('moment');

  _ = require('lodash');

  Promise = require('es6-promise').Promise;

  my = require("" + dir + "my");

  TwitterCilent = require("" + dir + "TwitterClient");

  twitterTest = require("" + dir + "twitter-test").twitterTest;

  twitterPostTest = require("" + dir + "twitter-post-test").twitterPostTest;

  UserProvider = require("" + dir + "model").UserProvider;

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
    app.use('/api/?', function(req, res, next) {
      console.log("======> " + req.originalUrl);
      if (!_.isUndefined(req.session.passport.user)) {
        return next();
      } else {
        return res.redirect('/');
      }
    });
    app.post('/api/twitterTest', function(req, res) {
      return twitterTest(req.body.user).then(function(data) {
        console.log('twitterTest data = ', data);
        return res.json({
          data: data
        });
      });
    });
    app.post('/api/twitterPostTest', function(req, res) {
      return twitterPostTest(req.body.user).then(function(data) {
        return res.json({
          data: data
        });
      });
    });
    app.get('/api/lists/list/:id?/:count?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient.getListsList({
        twitterIdStr: req.params.id,
        count: req.params.count
      }).then(function(data) {
        console.log('/api/lists/list/:id/:count data.length = ', data.length);
        return res.json({
          data: data
        });
      });
    });
    app.get('/api/lists/statuses/:id/:maxId?/:count?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient.getListsStatuses({
        listIdStr: req.params.id,
        maxId: req.params.maxId,
        count: req.params.count
      }).then(function(data) {
        console.log('/api/lists/list/:id/:count data.length = ', data.length);
        return res.json({
          data: data
        });
      });
    });
    return app.get('/api/timeline/:id/:maxId?/:count?', function(req, res) {
      var m, twitterClient;
      m = req.params.id === 'home' ? 'getHomeTimeline' : 'getUserTimeline';
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient[m]({
        listIdStr: req.params.id,
        maxId: req.params.maxId,
        count: req.params.count
      }).then(function(data) {
        console.log('/api/timeline/list/:id/:count data.length = ', data.length);
        return res.json({
          data: data
        });
      });
    });
  };

}).call(this);
