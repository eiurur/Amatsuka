(function() {
  var ConfigProvider, axios, my, path, settings, twitterUtils, _;

  _ = require('lodash');

  axios = require('axios');

  path = require('path');

  twitterUtils = require(path.resolve('build', 'lib', 'twitterUtils')).twitterUtils;

  ConfigProvider = require(path.resolve('build', 'lib', 'model')).ConfigProvider;

  my = require(path.resolve('build', 'lib', 'my')).my;

  settings = (process.env.NODE_ENV === 'production' ? require(path.resolve('build', 'lib', 'configs', 'production')) : require(path.resolve('build', 'lib', 'configs', 'development'))).settings;

  module.exports = function(app) {
    app.get("/api/mao", function(req, res) {
      var _config;
      _config = null;
      return ConfigProvider.findOneById({
        twitterIdStr: req.session.passport.user._json.id_str
      }, function(err, data) {
        _config = _.isNull(data) ? {} : JSON.parse(data.configStr);
        return axios.get("" + settings.MAO_HOST + "/api/tweets", {
          params: {
            maoToken: my.createHash(req.session.passport.user._json.id_str + settings.MAO_TOKEN_SALT),
            skip: req.query.skip - 0,
            limit: req.query.limit - 0,
            date: req.query.date
          }
        }).then(function(response) {
          var tweets;
          console.log(response.data.length);
          console.log(response.status);
          if (response.status !== 200) {
            new ((function() {
              throw Error('Not Authorized');
            })());
          }
          tweets = twitterUtils.normalizeTweets(response.data, _config);
          return res.send(tweets);
        })["catch"](function(err) {
          console.error(err);
          return res.status(401).send(err);
        });
      });
    });
    app.get("/api/mao/tweets/count", function(req, res) {
      return axios.get("" + settings.MAO_HOST + "/api/tweets/count", {
        params: {
          maoToken: my.createHash(req.session.passport.user._json.id_str + settings.MAO_TOKEN_SALT),
          date: req.query.date
        }
      }).then(function(response) {
        console.log(response);
        if (response.status !== 200) {
          new ((function() {
            throw Error('Not Authorized');
          })());
        }
        return res.send(response.data);
      })["catch"](function(err) {
        console.error('/api/map/tweets/count err ', err);
        return res.status(401).send(err);
      });
    });
    return app.get("/api/mao/stats/tweet/count", function(req, res) {
      return axios.get("" + settings.MAO_HOST + "/api/stats/tweet/count", {
        params: {
          maoToken: my.createHash(req.session.passport.user._json.id_str + settings.MAO_TOKEN_SALT),
          skip: req.query.skip - 0,
          limit: req.query.limit - 0
        }
      }).then(function(response) {
        console.log(response.data.length);
        console.log(response.status);
        if (response.status !== 200) {
          new ((function() {
            throw Error('Not Authorized');
          })());
        }
        return res.send(response.data);
      })["catch"](function(err) {
        console.error(err);
        return res.status(401).send(err);
      });
    });
  };

}).call(this);
