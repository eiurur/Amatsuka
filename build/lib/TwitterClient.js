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
            if (error) {
              console.log("getViaAPI " + params.method + "." + params.type + " e = ", error);
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
            if (error) {
              console.log("postViaAPI " + params.method + "." + params.type + " e = ", error);
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

    TwitterClient.prototype.getHomeTimeline = function(params) {
      var opts;
      opts = {
        count: params.count || settings.MAX_NUM_GET_TIMELINE_TWEET,
        include_entities: true,
        include_rts: true
      };
      if (!(params.maxId === '0' || params.maxId === 'undefined')) {
        opts.max_id = params.maxId;
      }
      console.log("opts = ", opts);
      return this.getViaAPI({
        method: 'getTimeline',
        type: 'home_timeline',
        params: opts
      });
    };

    TwitterClient.prototype.getUserTimeline = function(params) {
      var opts;
      opts = {
        user_id: params.twitterIdStr,
        count: params.count,
        include_entities: true,
        include_rts: true
      };
      if (!(params.maxId === '0' || params.maxId === 'undefined')) {
        opts.max_id = params.maxId;
      }
      if (params.count === '0' || params.count === 'undefined') {
        opts.count = settings.MAX_NUM_GET_TIMELINE_TWEET;
      }
      console.log("opts = ", opts);
      return this.getViaAPI({
        method: 'getTimeline',
        type: 'user_timeline',
        params: opts
      });
    };


    /*
    Tweet
     */

    TwitterClient.prototype.showStatus = function(params) {
      return this.getViaAPI({
        method: 'statuses',
        type: 'show',
        params: {
          id: params.tweetIdStr,
          include_my_retweet: true,
          include_entities: true
        }
      });
    };


    /*
    User
     */

    TwitterClient.prototype.showUsers = function(params) {
      return this.getViaAPI({
        method: 'users',
        type: 'show',
        params: {
          user_id: params.twitterIdStr || '',
          include_entities: true
        }
      });
    };


    /*
    List
     */

    TwitterClient.prototype.getListsList = function(params) {
      return this.getViaAPI({
        method: 'lists',
        type: 'list',
        params: {
          user_id: params.twitterIdStr || '',
          scren_name: params.screenName || '',
          count: params.count || settings.MAX_NUM_GET_LIST
        }
      });
    };

    TwitterClient.prototype.getListsStatuses = function(params) {
      var opts;
      opts = {
        list_id: params.listIdStr,
        count: ~~params.count || settings.MAX_NUM_GET_LIST_STATUSES,
        include_entities: true,
        include_rts: true
      };
      if (!(params.maxId === '0' || params.maxId === 'undefined')) {
        opts.max_id = params.maxId;
      }
      console.log("opts = ", opts);
      return this.getViaAPI({
        method: 'lists',
        type: 'statuses',
        params: opts
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

    TwitterClient.prototype.getListsMembers = function(params) {
      var opts;
      opts = {
        list_id: params.listIdStr,
        user_id: params.twitterIdStr || '',
        scren_name: params.screenName || '',
        count: ~~params.count || settings.MAX_NUM_GET_LIST_MEMBERS
      };
      return this.getViaAPI({
        method: 'lists',
        type: 'members',
        params: opts
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

    TwitterClient.prototype.createListsMembers = function(params) {
      return this.postViaAPI({
        method: 'lists',
        type: 'members/create',
        params: {
          list_id: params.listIdStr,
          user_id: params.twitterIdStr
        }
      });
    };

    TwitterClient.prototype.createAllListsMembers = function(params) {
      console.log(params);
      params.twitterIdStr = params.twitterIdStr || settings.defaultUserIds;
      return this.postViaAPI({
        method: 'lists',
        type: 'members/create_all',
        params: {
          list_id: params.listIdStr,
          user_id: params.twitterIdStr
        }
      });
    };

    TwitterClient.prototype.destroyListsMembers = function(params) {
      return this.postViaAPI({
        method: 'lists',
        type: 'members/destroy',
        params: {
          list_id: params.listIdStr,
          user_id: params.twitterIdStr
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
    Follow
     */

    TwitterClient.prototype.getFollowingList = function() {
      return this.getViaAPI({
        method: 'friends',
        type: 'list',
        params: {
          user_id: params.twitterIdStr || '',
          scren_name: params.screenName || '',
          count: params.count || settings.FRINEDS_LIST_COUNT
        }
      });
    };

    TwitterClient.prototype.getMyFollowingList = function() {
      return this.getViaAPI({
        method: 'friends',
        type: 'list',
        params: {
          user_id: this.user._json.id_str,
          count: params.count || settings.FRINEDS_LIST_COUNT
        }
      });
    };

    TwitterClient.prototype.getFollowersList = function(params) {
      return this.getViaAPI({
        method: 'followers',
        type: 'list',
        params: {
          user_id: params.twitterIdStr || '',
          scren_name: params.screenName || ''
        }
      });
    };

    TwitterClient.prototype.getMyFollowersList = function() {
      return this.getViaAPI({
        method: 'followers',
        type: 'list',
        params: {
          user_id: this.user._json.id_str,
          count: params.count || settings.FRINEDS_LIST_COUNT
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
          user_id: params.twitterIdStr || '',
          screen_name: params.screenName || '',
          count: params.count || settings.MAX_NUM_GET_FAV_TWEET_FROM_LIST
        }
      });
    };

    TwitterClient.prototype.createFav = function(params) {
      return this.postViaAPI({
        method: 'favorites',
        type: 'create',
        params: {
          id: params.tweetIdStr,
          include_entities: true
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


    /*
    ツイート関連(RTを含む)
     */

    TwitterClient.prototype.retweetStatus = function(params) {
      return this.postViaAPI({
        method: 'statuses',
        type: 'retweet',
        params: {
          id: params.tweetIdStr
        }
      });
    };

    TwitterClient.prototype.destroyStatus = function(params) {
      return this.showStatus(params).then((function(_this) {
        return function(data) {
          return _this.postViaAPI({
            method: 'statuses',
            type: 'destroy',
            params: {
              id: data.current_user_retweet.id_str
            }
          });
        };
      })(this));
    };

    return TwitterClient;

  })(TwitterClientDefine);

}).call(this);
