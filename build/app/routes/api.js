(function() {
  var ConfigProvider, Promise, TwitterCilent, UserProvider, dir, moment, my, settings, _;

  dir = '../../lib/';

  moment = require('moment');

  _ = require('lodash');

  Promise = require('es6-promise').Promise;

  my = require("" + dir + "my").my;

  TwitterCilent = require("" + dir + "TwitterClient");

  UserProvider = require("" + dir + "model").UserProvider;

  ConfigProvider = require("" + dir + "model").ConfigProvider;

  settings = process.env.NODE_ENV === 'production' ? require(dir + 'configs/production') : require(dir + 'configs/development');

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
    app.post('/api/download', function(req, res) {
      console.log("\n========> download\n");
      return my.loadBase64Data(req.body.url).then(function(base64Data) {
        return res.json({
          base64Data: base64Data
        });
      });
    });

    /*
    Twitter
     */
    app.post('/api/findUserById', function(req, res) {
      console.log("\n============> findUserById in API\n");
      return UserProvider.findUserById({
        twitterIdStr: req.session.passport.user._json.id_str
      }, function(err, data) {
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
      })["catch"](function(error) {
        console.log('/api/lists/list/:id/:count error = ', error);
        return res.json({
          error: error
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
      return ConfigProvider.findOneById({
        twitterIdStr: req.session.passport.user._json.id_str
      }, function(err, data) {
        var config, twitterClient;
        config = _.isNull(data) ? {} : JSON.parse(data.configStr);
        console.log('api lists config = ', config);
        twitterClient = new TwitterCilent(req.session.passport.user);
        return twitterClient.getListsStatuses({
          listIdStr: req.params.id,
          maxId: req.params.maxId,
          count: req.params.count,
          includeRetweet: config.includeRetweet
        }).then(function(data) {
          console.log('/api/lists/list/:id/:count data.length = ', data.length);
          return res.json({
            data: data
          });
        })["catch"](function(err) {
          console.log('/api/lists/list/:id/:count err ', err);
          return res.json({
            err: err
          });
        });
      });
    });
    app.get('/api/timeline/:id/:maxId?/:count?', function(req, res) {
      return ConfigProvider.findOneById({
        twitterIdStr: req.session.passport.user._json.id_str
      }, function(err, data) {
        var config, m, twitterClient;
        config = _.isNull(data) ? {} : JSON.parse(data.configStr);
        console.log('api timeline config = ', config);
        m = req.params.id === 'home' ? 'getHomeTimeline' : 'getUserTimeline';
        twitterClient = new TwitterCilent(req.session.passport.user);
        return twitterClient[m]({
          twitterIdStr: req.params.id,
          maxId: req.params.maxId,
          count: req.params.count,
          includeRetweet: config.includeRetweet
        }).then(function(data) {
          console.log('/api/timeline/:id/:count data.length = ', data.length);
          return res.json({
            data: data
          });
        })["catch"](function(err) {
          return res.json({
            err: err
          });
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
      })["catch"](function(err) {
        return res.json({
          err: err
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
    app.post('/api/statuses/destroy', function(req, res) {
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

    /*
     * Config
     */
    app.get('/api/config', function(req, res) {
      return ConfigProvider.findOneById({
        twitterIdStr: req.session.passport.user._json.id_str
      }, function(err, data) {
        console.log('get config: ', data);
        return res.json({
          data: data
        });
      });
    });
    return app.post('/api/config', function(req, res) {
      console.log(req.body);
      return ConfigProvider.upsert({
        twitterIdStr: req.session.passport.user._json.id_str,
        config: req.body.config
      }, function(err, data) {
        console.log('post config: ', data);
        return res.json({
          data: data
        });
      });
    });
  };

}).call(this);
