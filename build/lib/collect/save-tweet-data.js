(function() {
  var Promise, TLProvider, TwitterCilent, my, settings, _;

  _ = require('lodash');

  Promise = require('es6-promise').Promise;

  my = require('../my').my;

  TLProvider = require('../model').TLProvider;

  TwitterCilent = require('../TwitterClient');

  settings = (process.env.NODE_ENV === "production" ? require('../configs/production') : require('../configs/development')).settings;

  exports.saveTweetData = function(user) {
    var twitterClient;
    return twitterClient = new TwitterCilent(user);
  };

}).call(this);
