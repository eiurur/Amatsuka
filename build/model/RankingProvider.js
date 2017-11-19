(function() {
  var BaseProvider, ObjectId, Ranking, RankingProvider, RankingSchema, Schema, TweetSchema, mongoose,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  mongoose = require('mongoose');

  BaseProvider = require('./BaseProvider');

  Schema = mongoose.Schema;

  ObjectId = Schema.ObjectId;

  TweetSchema = new Schema({
    postedBy: {
      type: ObjectId,
      ref: 'Illustrator',
      index: true
    },
    tweet: {
      type: ObjectId,
      ref: 'PictTweet'
    }
  });

  RankingSchema = new Schema({
    year: {
      type: Date,
      "default": Date.now()
    },
    tweets: [TweetSchema],
    updatedAt: {
      type: Date,
      "default": Date.now()
    }
  });

  mongoose.model('Ranking', RankingSchema);

  RankingSchema.index({
    year: -1
  });

  Ranking = mongoose.model('Ranking');

  module.exports = RankingProvider = (function(superClass) {
    extend(RankingProvider, superClass);

    function RankingProvider() {
      RankingProvider.__super__.constructor.call(this, Ranking);
    }

    RankingProvider.prototype.find = function(params) {
      return new Promise(function(resolve, reject) {
        console.log("\n============> Ranking find\n");
        console.log(params);
        return Ranking.find({}).limit(params.limit || 100).skip(params.skip || 0).sort({
          updatedAt: -1
        }).exec(function(err, tweets) {
          if (err) {
            return reject(err);
          }
          return resolve(tweets);
        });
      });
    };

    RankingProvider.prototype.findOneAndUpdate = function(params) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          var data, options, query;
          console.log(params);
          query = {
            year: params.year
          };
          data = params;
          data.updateAt = new Date();
          options = {
            'new': true,
            upsert: true
          };
          return resolve(RankingProvider.__super__.findOneAndUpdate.call(_this, query, data, options));
        };
      })(this));
    };

    return RankingProvider;

  })(BaseProvider);

}).call(this);
