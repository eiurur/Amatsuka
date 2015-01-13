(function() {
  var NodeCache, Promise, TwitterClient, cheerio, my, request, settings, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require('lodash');

  request = require('request');

  cheerio = require('cheerio');

  NodeCache = require('node-cache');

  Promise = require('es6-promise').Promise;

  my = require('./my').my;

  settings = (process.env.NODE_ENV === "production" ? require('./configs/production') : require('./configs/development')).settings;

  module.exports = TwitterClient = (function() {
    function TwitterClient(user) {
      this.user = user;
      this.getUserIds = __bind(this.getUserIds, this);
      this.getMyFollowing = __bind(this.getMyFollowing, this);
    }

    TwitterClient.prototype.getViaAPI = function(params) {
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

    TwitterClient.prototype.postViaAPI = function(params) {
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

    TwitterClient.prototype.getHomeTimeline = function() {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return settings.twitterAPI.getTimeline('home_timeline', '', _this.user.twitter_token, _this.user.twitter_token_secret, function(error, data, response) {
            console.log(data.length);
            if (error) {
              console.log('twitter.get.home_timeline error =  ', error);
              return reject;
            }
            return resolve(data);
          });
        };
      })(this));
    };

    TwitterClient.prototype.getUserTimeline = function(params) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return settings.twitterAPI.getTimeline('user_timeline', {
            user_id: params.twitterIdStr || params.screenName
          }, _this.user.twitter_token, _this.user.twitter_token_secret, function(error, data, response) {
            console.log(data.length);
            if (error) {
              console.log('twitter.get.user_timeline error =  ', error);
              return reject;
            }
            return resolve(data);
          });
        };
      })(this));
    };

    TwitterClient.prototype.getListsList = function() {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return settings.twitterAPI.lists('list', '', _this.user.twitter_token, _this.user.twitter_token_secret, function(error, data, response) {
            console.log(data.length);
            if (error) {
              console.log('twitter.get.lists/list error =  ', error);
              return reject;
            }
            return resolve(data);
          });
        };
      })(this));
    };

    TwitterClient.prototype.getListsStatuses = function(params) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return settings.twitterAPI.lists('statuses', {
            list_id: params.listIdStr
          }, _this.user.twitter_token, _this.user.twitter_token_secret, function(error, data, response) {
            console.log(data.length);
            if (error) {
              console.log('twitter.get.lists/statuses error =  ', error);
            }
            return resolve(data);
          });
        };
      })(this));
    };

    TwitterClient.prototype.getListsShow = function(params) {
      console.log(params);
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return settings.twitterAPI.lists('show', {
            list_id: params.listIdStr
          }, _this.user.twitter_token, _this.user.twitter_token_secret, function(error, data, response) {
            console.log(data.length);
            return resolve(data);
          });
        };
      })(this));
    };

    TwitterClient.prototype.getListsMembers = function(params) {
      console.log(params);
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return settings.twitterAPI.lists('members', {
            list_id: params.listIdStr
          }, _this.user.twitter_token, _this.user.twitter_token_secret, function(error, data, response) {
            console.log(data.length);
            if (error) {
              console.log('twitter.get.lists/members error =  ', error);
              return reject;
            }
            return resolve(data);
          });
        };
      })(this));
    };

    TwitterClient.prototype.createLists = function(params) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return settings.twitterAPI.lists('create', {
            name: params.name,
            mode: params.mode
          }, _this.user.twitter_token, _this.user.twitter_token_secret, function(error, data, response) {
            console.log(data);
            if (error) {
              console.log('twitter.get.lists/create error =  ', error);
              return reject;
            }
            return resolve(data);
          });
        };
      })(this));
    };

    TwitterClient.prototype.destroyLists = function(params) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return settings.twitterAPI.lists('destroy', {
            list_id: params.listIdStr
          }, _this.user.twitter_token, _this.user.twitter_token_secret, function(error, data, response) {
            console.log(data);
            if (error) {
              console.log('twitter.get.lists/destroy error =  ', error);
              return reject;
            }
            return resolve(data);
          });
        };
      })(this));
    };

    TwitterClient.prototype.createMemberList = function(params) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return settings.twitterAPI.lists('members/create', {
            list_id: params.listIdStr,
            user_id: params.twitterIdStr
          }, _this.user.twitter_token, _this.user.twitter_token_secret, function(error, data, response) {
            console.log(data);
            if (error) {
              console.log('twitter.get.members/create error =  ', error);
              return reject;
            }
            return resolve(data);
          });
        };
      })(this));
    };

    TwitterClient.prototype.getMyFollowing = function() {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          console.log('getMyFollowing @user = ', _this.user.twitter_token);
          console.log('getMyFollowing @user = ', _this.user.twitter_token_secret);
          return settings.twitterAPI.friends('list', {
            user_id: _this.user._json.id_str,
            count: settings.FRINEDS_LIST_COUNT
          }, _this.user.twitter_token, _this.user.twitter_token_secret, function(error, data, response) {
            if (error) {
              console.log('twitter.get.myfollowing error =  ', error);
              return reject;
            }
            return resolve(data.users);
          });
        };
      })(this));
    };

    TwitterClient.prototype.getUserIds = function(user) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return settings.twitterAPI.friends('ids', {
            user_id: user.id_str
          }, _this.user.twitter_token, _this.user.twitter_token_secret, function(error, data, response) {
            if (error) {
              console.log('twitter.get.following error =  ', error);
              return reject;
            }
            return resolve(data.ids);
          });
        };
      })(this));
    };

    TwitterClient.prototype.getUsersIdsFollowingFollowing = function(users) {
      return Promise.all(_.map(users, (function(_this) {
        return function(user) {
          return _this.getUserIds(user);
        };
      })(this)));
    };

    return TwitterClient;

  })();

}).call(this);
