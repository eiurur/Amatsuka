(function() {
  var saveTweetData, settings, _;

  _ = require('lodash');

  saveTweetData = require('./save-tweet-data').saveTweetData;

  settings = (process.env.NODE_ENV === "production" ? require("../configs/production") : require("../configs/development")).settings;

  exports.startTask = function() {
    var requestAllUserTimeline, targetList;
    targetList = settings.targetList;
    requestAllUserTimeline = function() {
      var target;
      target = targetList.pop();
      if (_.isUndefined(target)) {
        clearInterval(requestAllUserTimeline);
        return;
      }
      console.log("======> " + target);
      return saveTweetData(target);
    };
    setInterval(requestAllUserTimeline, 2 * 1000);
    return requestAllUserTimeline();
  };

}).call(this);
