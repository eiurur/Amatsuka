(function() {
  var BaseProvider, ObjectId, Pict, PictProvider, PictSchema, PictTweetSchema, Schema, mongoose,
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

  PictSchema = new Schema({
    postedBy: {
      type: ObjectId,
      ref: 'Illustrator',
      index: true
    },
    pictTweetList: [PictTweetSchema],
    updatedAt: {
      type: Date,
      "default": Date.now()
    }
  });

  mongoose.model('Pict', PictSchema);

  PictSchema.index({
    twitterIdStr: 1,
    updatedAt: -1
  });

  Pict = mongoose.model('Pict');

  module.exports = PictProvider = (function(superClass) {
    extend(PictProvider, superClass);

    function PictProvider() {
      PictProvider.__super__.constructor.call(this, Pict);
    }

    PictProvider.prototype.find = function(params) {
      return new Promise(function(resolve, reject) {
        console.log("\n============> Pict find\n");
        return Pict.find({}).limit(params.limit || 20).skip(params.skip || 0).populate('postedBy').sort({
          updatedAt: -1
        }).exec(function(err, pictList) {
          if (err) {
            return reject(err);
          }
          return resolve(pictList);
        });
      });
    };

    PictProvider.prototype.findByIllustratorObjectId = function(params) {
      return new Promise(function(resolve, reject) {
        console.log("\n============> Pict findByIllustratorObjectId\n");
        console.log(params);
        return Pict.findOne({
          postedBy: params.postedBy
        }).populate('postedBy').sort({
          updatedAt: -1
        }).exec(function(err, pictList) {
          console.log(pictList);
          if (err) {
            return reject(err);
          }
          return resolve(pictList);
        });
      });
    };

    PictProvider.prototype.findOneAndUpdate = function(params) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          var data, options, query;
          console.log(params);
          query = {
            postedBy: params.postedBy
          };
          data = params;
          data.updateAt = new Date();
          options = {
            'new': true,
            upsert: true
          };
          return resolve(PictProvider.__super__.findOneAndUpdate.call(_this, query, data, options));
        };
      })(this));
    };

    PictProvider.prototype.count = function() {
      return new Promise(function(resolve, reject) {
        console.log("\n============> Pict count\n");
        return Pict.count({}, function(err, count) {
          console.log(count);
          if (err) {
            return reject(err);
          }
          return resolve(count);
        });
      });
    };

    return PictProvider;

  })(BaseProvider);

}).call(this);
