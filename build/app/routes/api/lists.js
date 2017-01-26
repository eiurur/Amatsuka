(function() {
  var ModelFactory, TweetFetcher, TwitterClient, _, chalk, my, path, settings;

  _ = require('lodash');

  path = require('path');

  chalk = require('chalk');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  TweetFetcher = require(path.resolve('build', 'lib', 'TweetFetcher'));

  my = require(path.resolve('build', 'lib', 'my')).my;

  settings = require(path.resolve('build', 'lib', 'configs', 'settings')).settings;

  ModelFactory = require(path.resolve('build', 'model', 'ModelFactory'));

  module.exports = function(app) {
    app.get('/api/lists/list/:id?/:count?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.getListsList({
        twitterIdStr: req.params.id,
        count: req.params.count
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(error) {
        return res.status(429).send(error);
      });
    });
    app.post('/api/lists/create', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.createLists({
        name: req.body.name,
        mode: req.body.mode
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(error) {
        return res.status(429).send(error);
      });
    });
    app.get('/api/lists/members/:id?/:count?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.getListsMembers({
        listIdStr: req.params.id,
        count: req.params.count
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(error) {
        return res.status(429).send(error);
      });
    });
    app.get('/api/lists/statuses/:id/:maxId?/:count?', function(req, res) {
      var opts;
      opts = {
        twitterIdStr: req.session.passport.user._json.id_str
      };
      return ModelFactory.create('config').findOneById(opts).then(function(data) {
        var config;
        config = _.isNull(data) ? {} : JSON.parse(data.configStr);
        return new TweetFetcher(req, res, 'getListsStatuses', null, config).fetchTweet();
      });
    });
    app.post('/api/lists/members/create', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.createListsMembers({
        listIdStr: req.body.listIdStr,
        twitterIdStr: req.body.twitterIdStr
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(error) {
        return res.status(429).send(error);
      });
    });
    app.post('/api/lists/members/create_all', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.createAllListsMembers({
        listIdStr: req.body.listIdStr,
        twitterIdStr: req.body.twitterIdStr
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(error) {
        return res.status(429).send(error);
      });
    });
    return app.post('/api/lists/members/destroy', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.destroyListsMembers({
        listIdStr: req.body.listIdStr,
        twitterIdStr: req.body.twitterIdStr
      }).then(function(data) {
        return res.send(data);
      })["catch"](function(error) {
        return res.status(429).send(error);
      });
    });
  };

}).call(this);
