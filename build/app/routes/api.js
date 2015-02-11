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
    app.post('/api/lists/create', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient.createLists({
        name: req.body.name,
        mode: req.body.mode
      }).then(function(data) {
        console.log('/api/lists/create', data.length);
        return res.json({
          data: data
        });
      });
    });
    app.get('/api/lists/members/:id?/:count?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient.getListsMembers({
        listIdStr: req.params.id,
        count: req.params.count
      }).then(function(data) {
        console.log('/api/lists/members/:id/:count data.length = ', data.length);
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
    app.get('/api/timeline/:id/:maxId?/:count?', function(req, res) {
      var m, twitterClient;
      m = req.params.id === 'home' ? 'getHomeTimeline' : 'getUserTimeline';
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient[m]({
        twitterIdStr: req.params.id,
        maxId: req.params.maxId,
        count: req.params.count
      }).then(function(data) {
        console.log('/api/timeline/:id/:count data.length = ', data.length);
        return res.json({
          data: data
        });
      });
    });
    app.get('/api/users/show/:id', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient.showUsers({
        twitterIdStr: req.params.id
      }).then(function(data) {
        return res.json({
          data: data
        });
      });
    });
    app.post('/api/lists/members/create', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient.createListsMembers({
        listIdStr: req.body.listIdStr,
        twitterIdStr: req.body.twitterIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      });
    });
    app.post('/api/lists/members/create_all', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient.createAllListsMembers({
        listIdStr: req.body.listIdStr,
        twitterIdStr: req.body.twitterIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      });
    });
    app.post('/api/lists/members/destroy', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient.destroyListsMembers({
        listIdStr: req.body.listIdStr,
        twitterIdStr: req.body.twitterIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      });
    });

    /*
    Fav
     */
    app.get('/api/favorites/lists/:id/:maxId?/:count?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient.getFavLists({
        twitterIdStr: req.params.id,
        maxId: req.params.maxId,
        count: req.params.count
      }).then(function(data) {
        return res.json({
          data: data
        });
      });
    });
    app.post('/api/favorites/create', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient.createFav({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      });
    });
    app.post('/api/favorites/destroy', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient.destroyFav({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      });
    });
    app.post('/api/statuses/retweet', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient.retweetStatus({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      });
    });
    return app.post('/api/statuses/destroy', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterCilent(req.session.passport.user);
      return twitterClient.destroyStatus({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      });
    });
  };

}).call(this);
