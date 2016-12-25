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
        console.time('Pict find');
        return Pict.find({}).limit(params.limit || 20).skip(params.skip || 0).populate('postedBy').sort({
          updatedAt: -1
        }).exec(function(err, pictList) {
          console.timeEnd('Pict find');
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
        console.time('Pict findByIllustratorObjectId');
        return Pict.findOne({
          postedBy: params.postedBy
        }).populate('postedBy').sort({
          updatedAt: -1
        }).exec(function(err, pictList) {
          console.timeEnd('Pict findByIllustratorObjectId');
          if (err) {
            return reject(err);
          }
          return resolve(pictList);
        });
      });
    };

    PictProvider.prototype.findOneAndUpdate = function(params) {
      return new Promise(function(resolve, reject) {
        var pict;
        pict = null;
        console.log("\n============> Pict upsert\n");
        pict = params;
        pict.updatedAt = new Date();
        return Pict.findOneAndUpdate({
          postedBy: params.postedBy
        }, pict, {
          upsert: true
        }, function(err, data) {
          if (err) {
            return reject(err);
          }
          return resolve(data);
        });
      });
    };

    PictProvider.prototype.count = function() {
      return new Promise(function(resolve, reject) {
        console.log("\n============> Pict count\n");
        console.time('Pict count');
        return Pict.count({}, function(err, count) {
          console.log(count);
          console.timeEnd('Pict count');
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
