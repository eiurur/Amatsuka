(function() {
  var ModelFactory, PictCollection, path;

  path = require('path');

  PictCollection = require(path.resolve('build', 'lib', 'PictCollection'));

  ModelFactory = require(path.resolve('build', 'model', 'ModelFactory'));

  module.exports = function(app) {
    app.get('/api/collect/count', function(req, res) {
      return ModelFactory.create('pict').count().then(function(count) {
        return res.json({
          count: count
        });
      })["catch"](function(err) {
        return console.log(err);
      });
    });
    app.get('/api/collect/picts', function(req, res, next) {
      var opts;
      opts = {
        twitterIdStr: req.query.twitterIdStr
      };
      return ModelFactory.create('illustrator').findById(opts).then(function(illustrator) {
        console.log(illustrator != null);
        if (illustrator == null) {
          next(err);
          return;
        }
        console.log(illustrator._id);
        return ModelFactory.create('pict').findByIllustratorObjectId({
          postedBy: illustrator._id
        });
      }).then(function(data) {
        console.log(data);
        console.log(data.postedBy);
        console.log(data.pictTweetList.length);
        return res.send(data);
      })["catch"](function(err) {
        return next(err);
      });
    });
    app.get('/api/collect/:skip?/:limit?', function(req, res, next) {
      var opts;
      opts = {
        skip: req.params.skip - 0,
        limit: req.params.limit - 0
      };
      return ModelFactory.create('pict').find(opts).then(function(data) {
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
        return res.send(data);
      })["catch"](function(err) {
        return next(err);
      });
    });
  };

}).call(this);
