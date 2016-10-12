(function() {
  var IllustratorProvider, PictCollection, PictProvider, TwitterClient, _, my, path;

  _ = require('lodash');

  path = require('path');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  my = require(path.resolve('build', 'lib', 'my')).my;

  IllustratorProvider = require(path.resolve('build', 'lib', 'model')).IllustratorProvider;

  PictProvider = require(path.resolve('build', 'lib', 'model')).PictProvider;

  module.exports = PictCollection = (function() {
    function PictCollection(user, illustratorTwitterIdStr, idx) {
      if (idx == null) {
        idx = 0;
      }
      this.twitterClient = new TwitterClient(user);
      this.illustrator = {
        twitterIdStr: illustratorTwitterIdStr
      };
      this.illustratorRawData = null;
      this.illustratorDBData = null;
      this.pictList = [];
      this.userTimelineMaxId = null;
      this.isContinue = true;
      this.PROFILE_REQUEST_INTERVAL = 70 * 1000 * idx;
      this.USER_TIMELINE_REQUEST_INTERVAL = 4 * 1000;
    }

    PictCollection.prototype.collectProfileAndPicts = function() {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          console.log('start collect, @PROFILE_REQUEST_INTERVAL = ', _this.PROFILE_REQUEST_INTERVAL);
          return my.delayPromise(_this.PROFILE_REQUEST_INTERVAL).then(function() {
            return _this.getIllustratorTwitterProfile();
          }).then(function(data) {
            return _this.setIllustratorRawData(data);
          }).then(function() {
            return _this.getIllustratorRawData();
          }).then(function(illustratorRawData) {
            return _this.setUserTimelineMaxId(illustratorRawData.status.id_str);
          }).then(function() {
            return _this.normalizeIllustratorData();
          }).then(function() {
            return _this.updateIllustratorData();
          }).then(function(data) {
            return _this.setIllustratorDBData(data);
          }).then(function() {
            return _this.aggregatePict();
          }).then(function(pickupedPictList) {
            return _this.updatePictListData(pickupedPictList);
          }).then(function(data) {
            return resolve('Fin');
          })["catch"](function(err) {
            return reject(err);
          });
        };
      })(this));
    };


    /*
    Pict
     */

    PictCollection.prototype.aggregatePict = function() {
      return my.promiseWhile(((function(_this) {
        return function() {
          return _this.isContinue;
        };
      })(this)), (function(_this) {
        return function() {
          return new Promise(function(resolve, reject) {
            my.delayPromise(_this.USER_TIMELINE_REQUEST_INTERVAL).then(function(data) {
              return _this.twitterClient.getUserTimeline({
                twitterIdStr: _this.illustrator.twitterIdStr,
                maxId: _this.userTimelineMaxId,
                count: '200',
                includeRetweet: false
              });
            }).then(function(data) {
              var tweetListIncludePict;
              if (_.isUndefined(data)) {
                _this.isContinue = false;
                reject();
                return;
              }
              if (data.length < 2) {
                _this.isContinue = false;
                resolve();
                return;
              }
              if (_.isNull(data[data.length - 1]) || _.isUndefined(data[data.length - 1])) {
                _this.isContinue = false;
                console.log('_.isNull(data[data.length - 1]) or _.isUndefined(data[data.length - 1])');
                console.log(' _.isEmpty @pictList = ', _.isEmpty(_this.pictList));
                if (_.isEmpty(_this.pictList)) {
                  reject();
                }
                resolve();
                return;
              }
              _this.setUserTimelineMaxId(my.decStrNum(data[data.length - 1].id_str));
              tweetListIncludePict = _.chain(data).filter(function(tweet) {
                return _.has(tweet, 'extended_entities') && !_.isEmpty(tweet.extended_entities.media);
              }).map(function(tweet) {
                var o;
                o = {};
                o.tweetIdStr = tweet.id_str;
                o.totalNum = tweet.retweet_count + tweet.favorite_count;
                o.mediaUrl = tweet.extended_entities.media[0].media_url_https;
                o.mediaOrigUrl = tweet.extended_entities.media[0].media_url_https + ':orig';
                o.displayUrl = tweet.extended_entities.media[0].display_url;
                o.expandedUrl = tweet.extended_entities.media[0].expanded_url;
                return o;
              }).value();
              _this.pictList = _this.pictList.concat(tweetListIncludePict);
              return resolve();
            });
          });
        };
      })(this)).then((function(_this) {
        return function(data) {
          console.log("\n\nAll =============>");
          console.log(_this.pictList.length);
          return _this.pickupPictListTop12(_this.pictList);
        };
      })(this))["catch"]((function(_this) {
        return function(err) {
          console.log('Reject aggregatePict');
          return _this.pickupPictListTop12(_this.pictList);
        };
      })(this));
    };

    PictCollection.prototype.pickupPictListTop12 = function(pictList) {
      var pictListTop12;
      return pictListTop12 = _.chain(pictList).sortBy('totalNum').reverse().slice(0, 12).value();
    };

    PictCollection.prototype.updatePictListData = function(pickupedPictList) {
      console.log('===> updatePictListData :: ', pickupedPictList);
      console.log('===> @illustratorDBData._id :: ', this.illustratorDBData._id);
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return PictProvider.findOneAndUpdate({
            postedBy: _this.illustratorDBData._id,
            pictTweetList: pickupedPictList
          }).then(function(data) {
            return resolve(data);
          })["catch"](function(err) {
            return reject(err);
          });
        };
      })(this));
    };

    PictCollection.prototype.setUserTimelineMaxId = function(maxId) {
      return this.userTimelineMaxId = maxId;
    };


    /*
    Utils (From Front. TweetService)
     */

    PictCollection.prototype.getExpandedURLFromURL = function(entities) {
      if (!_.has(entities, 'url')) {
        return '';
      }
      return entities.url.urls;
    };

    PictCollection.prototype.restoreProfileUrl = function() {
      var expandedUrlListInUrl;
      expandedUrlListInUrl = this.getExpandedURLFromURL(this.illustratorRawData.entities);
      return _.each(expandedUrlListInUrl, (function(_this) {
        return function(urls) {
          return _this.illustratorRawData.url = _this.illustratorRawData.url.replace(urls.url, urls.expanded_url);
        };
      })(this));
    };


    /*
    Illustrator
     */

    PictCollection.prototype.getIllustratorTwitterProfile = function() {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return _this.twitterClient.showUsers({
            twitterIdStr: _this.illustrator.twitterIdStr
          }).then(function(data) {
            return resolve(data);
          })["catch"](function(err) {
            return reject(err);
          });
        };
      })(this));
    };

    PictCollection.prototype.setIllustratorRawData = function(data) {
      return this.illustratorRawData = data;
    };

    PictCollection.prototype.getIllustratorRawData = function() {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          var ref;
          if (((ref = _this.illustratorRawData.status) != null ? ref.id_str : void 0) != null) {
            return resolve(_this.illustratorRawData);
          }
          return reject('getIllustratorRawData Error ::');
        };
      })(this));
    };

    PictCollection.prototype.setIllustratorDBData = function(data) {
      return this.illustratorDBData = data;
    };

    PictCollection.prototype.normalizeIllustratorData = function() {
      this.restoreProfileUrl();
      return this.illustrator = {
        twitterIdStr: this.illustratorRawData.id_str,
        name: this.illustratorRawData.name,
        screenName: this.illustratorRawData.screen_name,
        icon: this.illustratorRawData.profile_image_url_https,
        url: this.illustratorRawData.url,
        description: this.illustratorRawData.description
      };
    };

    PictCollection.prototype.getIllustratorData = function() {
      return this.illustrator;
    };

    PictCollection.prototype.updateIllustratorData = function() {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return IllustratorProvider.findOneAndUpdate({
            illustrator: _this.illustrator
          }, function(err, data) {
            if (err) {
              return reject(err);
            }
            return resolve(data);
          });
        };
      })(this));
    };

    return PictCollection;

  })();

}).call(this);
