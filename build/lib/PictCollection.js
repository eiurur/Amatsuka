(function() {
  var IllustratorProvider, PictCollection, PictProvider, TwitterClient, my, path, _;

  _ = require('lodash');

  path = require('path');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  my = require(path.resolve('build', 'lib', 'my')).my;

  IllustratorProvider = require(path.resolve('build', 'lib', 'model')).IllustratorProvider;

  PictProvider = require(path.resolve('build', 'lib', 'model')).PictProvider;

  module.exports = PictCollection = (function() {
    function PictCollection(user, illustratorTwitterIdStr) {
      this.twitterClient = new TwitterClient(user);
      this.illustrator = {
        twitterIdStr: illustratorTwitterIdStr
      };
      this.illustratorRawData = null;
      this.illustratorDBData = null;
      this.pictList = [];
      this.userTimelineMaxId = null;
      this.isContinue = true;
    }


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
            _this.twitterClient.getUserTimeline({
              twitterIdStr: _this.illustrator.twitterIdStr,
              maxId: _this.userTimelineMaxId,
              count: '200',
              includeRetweet: false
            }).then(function(data) {
              var tweetListIncludePict;
              if (_.isUndefined(data)) {
                _this.isContinue = false;
                reject();
              }
              if (data.length < 2) {
                _this.isContinue = false;
                resolve();
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
              console.log("\n\n=============>");
              console.log(tweetListIncludePict);
              console.log(tweetListIncludePict.length);
              _this.pictList = _this.pictList.concat(tweetListIncludePict);
              return resolve();
            });
          });
        };
      })(this)).then((function(_this) {
        return function(data) {
          console.log("\n\nAll =============>");
          console.log(_this.pictList);
          console.log(_this.pictList.length);
          return _this.pickupPictListTop12(_this.pictList);
        };
      })(this));
    };

    PictCollection.prototype.pickupPictListTop12 = function(pictList) {
      var pictListTop12;
      return pictListTop12 = _.chain(pictList).sortBy('totalNum').reverse().slice(0, 12).value();
    };

    PictCollection.prototype.updatePictListData = function(pickupedPictList) {
      return PictProvider.findOneAndUpdate({
        postedBy: this.illustratorDBData._id,
        pictTweetList: pickupedPictList
      });
    };

    PictCollection.prototype.setUserTimelineMaxId = function(maxId) {
      return this.userTimelineMaxId = maxId;
    };


    /*
    Illustrator
     */

    PictCollection.prototype.getIllustratorTwitterProfile = function() {
      return this.twitterClient.showUsers({
        twitterIdStr: this.illustrator.twitterIdStr
      });
    };

    PictCollection.prototype.setIllustratorRawData = function(data) {
      return this.illustratorRawData = data;
    };

    PictCollection.prototype.getIllustratorRawData = function() {
      return this.illustratorRawData;
    };

    PictCollection.prototype.setIllustratorDBData = function(data) {
      return this.illustratorDBData = data;
    };

    PictCollection.prototype.normalizeIllustratorData = function() {
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
