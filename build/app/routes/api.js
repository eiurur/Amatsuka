(function() {
  var ConfigProvider, PictCollection, PictProvider, TwitterClient, UserProvider, moment, my, path, settings, twitterUtils, _;

  moment = require('moment');

  _ = require('lodash');

  path = require('path');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  PictCollection = require(path.resolve('build', 'lib', 'PictCollection'));

  my = require(path.resolve('build', 'lib', 'my')).my;

  twitterUtils = require(path.resolve('build', 'lib', 'twitterUtils')).twitterUtils;

  UserProvider = require(path.resolve('build', 'lib', 'model')).UserProvider;

  ConfigProvider = require(path.resolve('build', 'lib', 'model')).ConfigProvider;

  PictProvider = require(path.resolve('build', 'lib', 'model')).PictProvider;

  settings = process.env.NODE_ENV === 'production' ? require(path.resolve('build', 'lib', 'configs', 'production')) : require(path.resolve('build', 'lib', 'configs', 'development'));

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
      console.log("\n========> download, " + req.body.url + "\n");
      return my.loadBase64Data(req.body.url).then(function(base64Data) {
        console.log('base64toBlob', base64Data.length);
        return res.json({
          base64Data: base64Data
        });
      });
    });
    app.get('/api/collect/:skip?/:limit?', function(req, res) {
      return PictProvider.find({
        skip: req.params.skip - 0,
        limit: req.params.limit - 0
      }).then(function(data) {
        return res.send(data);
      });
    });
    app.post('/api/collect', function(req, res) {
      var pictCollection;
      pictCollection = new PictCollection(req.session.passport.user, req.body.twitterIdStr);
      return pictCollection.getIllustratorTwitterProfile().then(function(data) {
        return pictCollection.setIllustratorRawData(data);
      }).then(function() {
        return pictCollection.setUserTimelineMaxId(pictCollection.getIllustratorRawData().status.id_str);
      }).then(function() {
        return pictCollection.normalizeIllustratorData();
      }).then(function() {
        return pictCollection.updateIllustratorData();
      }).then(function(data) {
        return pictCollection.setIllustratorDBData(data);
      }).then(function() {
        return pictCollection.aggregatePict();
      }).then(function(pickupedPictList) {
        return pictCollection.updatePictListData(pickupedPictList);
      }).then(function(data) {
        console.log('End PictProvider.findOneAndUpdate data = ', data);
        return res.send(data);
      })["catch"](function(err) {
        return console.log(err);
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
      twitterClient = new TwitterClient(req.session.passport.user);
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
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.createLists({
        name: req.body.name,
        mode: req.body.mode
      }).then(function(data) {
        console.log('/api/lists/create', data.length);
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.get('/api/lists/members/:id?/:count?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.getListsMembers({
        listIdStr: req.params.id,
        count: req.params.count
      }).then(function(data) {
        console.log('/api/lists/members/:id/:count data.length = ', data.length);
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
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
        twitterClient = new TwitterClient(req.session.passport.user);
        return twitterClient.getListsStatuses({
          listIdStr: req.params.id,
          maxId: req.params.maxId,
          count: req.params.count,
          includeRetweet: config.includeRetweet
        }).then(function(tweets) {
          var tweetsCleaned, tweetsExcluededNgUser;
          console.log('/api/lists/list/:id/:count tweets.length = ', tweets.length);
          tweetsExcluededNgUser = twitterUtils.excludeTweetBasedOnNgUser(tweets, config.ngUsername);
          tweetsCleaned = twitterUtils.excludeTweetBasedOnNgWord(tweetsExcluededNgUser, config.ngWord);
          return res.json({
            data: tweetsCleaned
          });
        })["catch"](function(error) {
          console.log('/api/lists/list/:id/:count error ', error);
          return res.json({
            error: error
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
        twitterClient = new TwitterClient(req.session.passport.user);
        return twitterClient[m]({
          twitterIdStr: req.params.id,
          maxId: req.params.maxId,
          count: req.params.count,
          includeRetweet: config.includeRetweet
        }).then(function(tweets) {
          var tweetsCleaned, tweetsExcluededNgUser;
          console.log('/api/timeline/:id/:count tweets.length = ', tweets.length);
          tweetsExcluededNgUser = twitterUtils.excludeTweetBasedOnNgUser(tweets, config.ngUsername);
          tweetsCleaned = twitterUtils.excludeTweetBasedOnNgWord(tweetsExcluededNgUser, config.ngWord);
          return res.json({
            data: tweetsCleaned
          });
        })["catch"](function(error) {
          return res.json({
            error: error
          });
        });
      });
    });
    app.get('/api/statuses/show/:id', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.showStatuses({
        tweetIdStr: req.params.id
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.get('/api/users/show/:id', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.showUsers({
        twitterIdStr: req.params.id
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.get('/api/friends/list/:id?/:cursor?/:count?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.getFollowingList({
        twitterIdStr: req.params.id,
        cursor: req.params.cursor - 0,
        count: req.params.count - 0
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/lists/members/create', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.createListsMembers({
        listIdStr: req.body.listIdStr,
        twitterIdStr: req.body.twitterIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/lists/members/create_all', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.createAllListsMembers({
        listIdStr: req.body.listIdStr,
        twitterIdStr: req.body.twitterIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/lists/members/destroy', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.destroyListsMembers({
        listIdStr: req.body.listIdStr,
        twitterIdStr: req.body.twitterIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });

    /*
    Fav
     */
    app.get('/api/favorites/lists/:id/:maxId?/:count?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.getFavLists({
        twitterIdStr: req.params.id,
        maxId: req.params.maxId,
        count: req.params.count
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/favorites/create', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.createFav({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/favorites/destroy', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.destroyFav({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/statuses/retweet', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.retweetStatus({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/statuses/destroy', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.destroyStatus({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
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
