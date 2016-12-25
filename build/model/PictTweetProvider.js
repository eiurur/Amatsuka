(function() {
  var BaseProvider, ObjectId, PictTweet, PictTweetProvider, PictTweetSchema, Schema, mongoose,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  mongoose = require('mongoose');

  BaseProvider = require('./BaseProvider');

  Schema = mongoose.Schema;

  ObjectId = Schema.ObjectId;

  PictTweetSchema = new Schema({
    tweetIdStr: String,
    totalNum: Number,
    mediaUrl: String,
    mediaOrigUrl: String,
    expandedUrl: String,
    displayUrl: String
  });

  mongoose.model('PictTweet', PictTweetSchema);

  PictTweet = mongoose.model('PictTweet');

  module.exports = PictTweetProvider = (function(superClass) {
    extend(PictTweetProvider, superClass);

    function PictTweetProvider() {
      PictTweetProvider.__super__.constructor.call(this, PictTweet);
    }

    PictTweetProvider.prototype.findPictTweetById = function(params, callback) {
      console.log("\n============> PictTweet findPictTweetByID\n");
      return PictTweet.findOne({
        twitterIdStr: params.twitterIdStr
      }, function(err, user) {
        return callback(err, user);
      });
    };

    PictTweetProvider.prototype.findOneAndUpdate = function(params, callback) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          var data, options, query;
          console.log(params);
          query = {
            twitterIdStr: params.user.twitterIdStr
          };
          data = params.user;
          data.updatedAt = Date.now();
          options = {
            'new': true,
            upsert: true
          };
          return resolve(_this.findOneAndUpdate(query, data, options));
        };
      })(this));
    };

    return PictTweetProvider;

  })(BaseProvider);

}).call(this);
