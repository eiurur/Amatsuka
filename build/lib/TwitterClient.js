(function() {
  var NodeCache, Promise, TwitterClient, TwitterClientDefine, cheerio, my, request, settings, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ = require('lodash');

  request = require('request');

  cheerio = require('cheerio');

  NodeCache = require('node-cache');

  Promise = require('es6-promise').Promise;

  my = require('./my').my;

  settings = (process.env.NODE_ENV === "production" ? require('./configs/production') : require('./configs/development')).settings;

  TwitterClientDefine = (function() {
    function TwitterClientDefine(user) {
      this.user = user;
    }

    TwitterClientDefine.prototype.getViaAPI = function(params) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return settings.twitterAPI[params.method](params.type, params.params, _this.user.twitter_token, _this.user.twitter_token_secret, function(error, data, response) {
            console.log(data.length);
            if (error) {
              console.log("twitter." + params.method + " error =  ", error);
              return reject(error);
            }
            return resolve(data);
          });
        };
      })(this));
    };

    TwitterClientDefine.prototype.postViaAPI = function(params) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return settings.twitterAPI[params.method](params.type, params.params, _this.user.twitter_token, _this.user.twitter_token_secret, function(error, data, response) {
            console.log(data.length);
            if (error) {
              console.log("twitter." + params.method + " error =  ", error);
              return reject(error);
            }
            return resolve(data);
          });
        };
      })(this));
    };

    return TwitterClientDefine;

  })();

  module.exports = TwitterClient = (function(_super) {
    __extends(TwitterClient, _super);

    function TwitterClient() {
      this.getUserIds = __bind(this.getUserIds, this);
      return TwitterClient.__super__.constructor.apply(this, arguments);
    }

    TwitterClient.prototype.getHomeTimeline = function() {
      return this.getViaAPI({
        method: 'getTimeline',
        type: 'home_timeline',
        params: ''
      });
    };

    TwitterClient.prototype.getUserTimeline = function(params) {
      return this.getViaAPI({
        method: 'user_timeline',
        type: 'home_timeline',
        params: {
          user_id: params.twitterIdStr || params.screenName
        }
      });
    };


    /*
    List
     */

    TwitterClient.prototype.getListsList = function() {
      return this.getViaAPI({
        method: 'lists',
        type: 'list',
        params: ''
      });
    };

    TwitterClient.prototype.getListsStatuses = function(params) {
      return this.getViaAPI({
        method: 'lists',
        type: 'statuses',
        params: {
          list_id: params.listIdStr
        }
      });
    };

    TwitterClient.prototype.getListsShow = function(params) {
      return this.getViaAPI({
        method: 'lists',
        type: 'show',
        params: {
          list_id: params.listIdStr
        }
      });
    };

    TwitterClient.prototype.destroyListsMembers = function(params) {
      return this.getViaAPI({
        method: 'lists',
        type: 'show',
        params: {
          list_id: params.listIdStr
        }
      });
    };

    TwitterClient.prototype.getListsMembers = function(params) {
      return this.getViaAPI({
        method: 'lists',
        type: 'members',
        params: {
          list_id: params.listIdStr,
          user_id: params.twitterIdStr || '',
          scren_name: params.screenName || ''
        }
      });
    };

    TwitterClient.prototype.createLists = function(params) {
      return this.postViaAPI({
        method: 'lists',
        type: 'create',
        params: {
          name: params.name,
          mode: params.mode
        }
      });
    };

    TwitterClient.prototype.destroyLists = function(params) {
      return this.postViaAPI({
        method: 'lists',
        type: 'destroy',
        params: {
          list_id: params.listIdStr
        }
      });
    };

    TwitterClient.prototype.createMemberList = function(params) {
      return this.postViaAPI({
        method: 'lists',
        type: 'members/create',
        params: {
          list_id: params.listIdStr,
          user_id: params.twitterIdStr
        }
      });
    };

    TwitterClient.prototype.getMyFollowing = function() {
      return this.getViaAPI({
        method: 'friends',
        type: 'list',
        params: {
          user_id: this.user._json.id_str,
          count: settings.FRINEDS_LIST_COUNT
        }
      });
    };

    TwitterClient.prototype.getUserIds = function(params) {
      return this.getViaAPI({
        method: 'friends',
        type: 'list',
        params: {
          user_id: params.user.id_str
        }
      });
    };


    /*
    fav
     */

    TwitterClient.prototype.getFavList = function(params) {
      return this.getViaAPI({
        method: 'favorites',
        type: 'list',
        params: {
          user_id: params.twitterIdStr || params.screenName
        }
      });
    };

    TwitterClient.prototype.createFav = function(params) {
      return this.postViaAPI({
        method: 'favorites',
        type: 'create',
        params: {
          id: params.tweetIdStr
        }
      });
    };

    TwitterClient.prototype.destroyFav = function(params) {
      return this.postViaAPI({
        method: 'favorites',
        type: 'destroy',
        params: {
          id: params.tweetIdStr
        }
      });
    };

    return TwitterClient;

  })(TwitterClientDefine);

}).call(this);
