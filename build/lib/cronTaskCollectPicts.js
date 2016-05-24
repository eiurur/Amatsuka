(function() {
  var IllustratorProvider, PictCollection, Promise, path, settings, _;

  path = require('path');

  _ = require('lodash');

  Promise = require("bluebird");

  PictCollection = require(path.resolve('build', 'lib', 'PictCollection'));

  IllustratorProvider = require(path.resolve('build', 'lib', 'model')).IllustratorProvider;

  settings = (process.env.NODE_ENV === 'production' ? require(path.resolve('build', 'lib', 'configs', 'production')) : require(path.resolve('build', 'lib', 'configs', 'development'))).settings;

  exports.cronTaskCollectPicts = function() {
    return IllustratorProvider.find().then(function(profileList) {
      var promises, user;
      console.log(profileList.length);
      user = {
        _json: {
          id_str: settings.TW_ID_STR
        },
        twitter_token: settings.TW_AT,
        twitter_token_secret: settings.TW_AS
      };
      promises = [];
      profileList.forEach(function(profile, idx) {
        var pictCollection;
        pictCollection = new PictCollection(user, profile.twitterIdStr, idx);
        return promises.push(pictCollection.collectProfileAndPicts());
      });
      return Promise.all(promises).then(function(resultList) {
        console.log('Succeeded!');
      })["catch"](function(err) {
        console.error('Failed.', err);
      });
    });
  };

}).call(this);
