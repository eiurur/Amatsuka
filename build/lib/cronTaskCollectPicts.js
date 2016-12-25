(function() {
  var EggSlicer, ModelFactory, PictCollection, Promise, _, path, settings;

  path = require('path');

  EggSlicer = require('egg-slicer');

  _ = require('lodash');

  Promise = require("bluebird");

  PictCollection = require(path.resolve('build', 'lib', 'PictCollection'));

  settings = require(path.resolve('build', 'lib', 'configs', 'settings')).settings;

  ModelFactory = require(path.resolve('build', 'model', 'ModelFactory'));

  exports.cronTaskCollectPicts = function() {
    return ModelFactory.create('illustrator').find().then(function(profileList) {
      var slicedProfileList;
      console.log(profileList.length);
      console.log(settings.TWS);
      console.log(settings.TWS.length);
      slicedProfileList = EggSlicer.slice(profileList, settings.TWS.length);
      return slicedProfileList.map((function(_this) {
        return function(pl, i) {
          var promises, user;
          user = {
            _json: {
              id_str: settings.TWS[i].TW_ID_STR
            },
            twitter_token: settings.TWS[i].TW_AT,
            twitter_token_secret: settings.TWS[i].TW_AS
          };
          promises = [];
          pl.forEach(function(profile, idx) {
            var pictCollection;
            pictCollection = new PictCollection(user, profile.twitterIdStr, idx);
            return promises.push(pictCollection.collectProfileAndPicts());
          });
          return Promise.all(promises).then(function(resultList) {
            console.log('Succeeded!');
          })["catch"](function(err) {
            console.error('Failed.', err);
          });
        };
      })(this));
    });
  };

}).call(this);
