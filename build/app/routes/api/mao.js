(function() {
  var axios, configMiddleware, my, path, settings, twitterUtils;

  axios = require('axios');

  path = require('path');

  twitterUtils = require(path.resolve('build', 'lib', 'twitterUtils')).twitterUtils;

  my = require(path.resolve('build', 'lib', 'my')).my;

  settings = require(path.resolve('build', 'lib', 'configs', 'settings')).settings;

  configMiddleware = require(path.resolve('build', 'app', 'routes', 'middlewares', 'configMiddleware'));

  module.exports = function(app) {
    app.get("/api/mao", configMiddleware.getConfig, function(req, res) {
      return axios.get(settings.MAO_HOST + "/api/tweets", {
        params: {
          maoToken: my.createHash(req.session.passport.user._json.id_str + settings.MAO_TOKEN_SALT),
          skip: req.query.skip - 0,
          limit: req.query.limit - 0,
          date: req.query.date
        }
      }).then(function(response) {
        var tweets;
        if (response.status !== 200) {
          new ((function() {
            throw Error('Not Authorized');
          })());
        }
        tweets = twitterUtils.normalizeTweets(response.data, req.config);
        return res.send(tweets);
      })["catch"](function(err) {
        console.error(err);
        return res.status(401).send(err);
      });
    });
    app.get("/api/mao/tweets/count", function(req, res) {
      return axios.get(settings.MAO_HOST + "/api/tweets/count", {
        params: {
          maoToken: my.createHash(req.session.passport.user._json.id_str + settings.MAO_TOKEN_SALT),
          date: req.query.date
        }
      }).then(function(response) {
        if (response.status !== 200) {
          new ((function() {
            throw Error('Not Authorized');
          })());
        }
        return res.send(response.data);
      })["catch"](function(err) {
        console.error('/api/mao/tweets/count err ', err);
        return res.status(401).send(err);
      });
    });
    return app.get("/api/mao/stats/tweet/count", function(req, res) {
      return axios.get(settings.MAO_HOST + "/api/stats/tweet/count", {
        params: {
          maoToken: my.createHash(req.session.passport.user._json.id_str + settings.MAO_TOKEN_SALT),
          skip: req.query.skip - 0,
          limit: req.query.limit - 0
        }
      }).then(function(response) {
        if (response.status !== 200) {
          new ((function() {
            throw Error('Not Authorized');
          })());
        }
        return res.send(response.data);
      })["catch"](function(err) {
        console.error('/api/mao/stats/tweets/count err ', err);
        return res.status(401).send(err);
      });
    });
  };

}).call(this);
