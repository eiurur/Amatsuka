(function() {
  var PictCollection, PictProvider, path, settings, _;

  _ = require('lodash');

  path = require('path');

  PictCollection = require(path.resolve('build', 'lib', 'PictCollection'));

  PictProvider = require(path.resolve('build', 'lib', 'model')).PictProvider;

  settings = process.env.NODE_ENV === 'production' ? require(path.resolve('build', 'lib', 'configs', 'production')) : require(path.resolve('build', 'lib', 'configs', 'development'));

  module.exports = function(app) {
    app.get('/api/collect/count', function(req, res) {
      return PictProvider.count().then(function(count) {
        return res.json({
          count: count
        });
      })["catch"](function(err) {
        return console.log(err);
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
    return app.post('/api/collect/profile', function(req, res) {
      var pictCollection;
      pictCollection = new PictCollection(req.session.passport.user, req.body.twitterIdStr);
      return pictCollection.getIllustratorTwitterProfile().then(function(data) {
        return pictCollection.setIllustratorRawData(data);
      }).then(function() {
        return pictCollection.getIllustratorRawData();
      }).then(function(illustratorRawData) {
        return pictCollection.setUserTimelineMaxId(illustratorRawData.status.id_str);
      }).then(function() {
        return pictCollection.normalizeIllustratorData();
      }).then(function() {
        return pictCollection.updateIllustratorData();
      }).then(function(data) {
        return pictCollection.setIllustratorDBData(data);
      }).then(function(data) {
        console.log('End PictProvider.findOneAndUpdate data = ', data);
        return res.send(data);
      })["catch"](function(err) {
        return console.log(err);
      });
    });
  };

}).call(this);
