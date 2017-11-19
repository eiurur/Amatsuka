(function() {
  var BaseProvider, Illustrator, IllustratorProvider, IllustratorSchema, ObjectId, Schema, mongoose,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  mongoose = require('mongoose');

  BaseProvider = require('./BaseProvider');

  Schema = mongoose.Schema;

  ObjectId = Schema.ObjectId;

  IllustratorSchema = new Schema({
    twitterIdStr: {
      type: String,
      unique: true,
      index: true
    },
    name: String,
    screenName: String,
    icon: String,
    url: String,
    profileBackgroundColor: String,
    profileBackgroundImageUrl: String,
    profileBannerUrl: String,
    description: String,
    createdAt: {
      type: Date,
      "default": Date.now()
    },
    updatedAt: {
      type: Date,
      "default": Date.now()
    }
  });

  mongoose.model('Illustrator', IllustratorSchema);

  IllustratorSchema.index({
    twitterIdStr: 1
  });

  Illustrator = mongoose.model('Illustrator');

  module.exports = IllustratorProvider = (function(superClass) {
    extend(IllustratorProvider, superClass);

    function IllustratorProvider() {
      IllustratorProvider.__super__.constructor.call(this, Illustrator);
    }

    IllustratorProvider.prototype.find = function(params) {
      return new Promise(function(resolve, reject) {
        console.log("\n============> Illustrator find\n");
        return Illustrator.find({}).sort({
          updatedAt: -1
        }).exec(function(err, illustratorList) {
          if (err) {
            return reject(err);
          }
          return resolve(illustratorList);
        });
      });
    };

    IllustratorProvider.prototype.findById = function(params) {
      return new Promise(function(resolve, reject) {
        var opts;
        console.log("\n============> Illustrator findUserByID\n");
        console.log(params);
        opts = {
          twitterIdStr: params.twitterIdStr
        };
        return Illustrator.where(opts).findOne(function(err, user) {
          if (err) {
            return reject(err);
          }
          return resolve(user);
        });
      });
    };

    IllustratorProvider.prototype.findOneAndUpdate = function(params) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          var data, options, query;
          console.log(params);
          query = {
            twitterIdStr: params.illustrator.twitterIdStr
          };
          data = params.illustrator;
          data.updatedAt = Date.now();
          options = {
            'new': true,
            upsert: true
          };
          return resolve(IllustratorProvider.__super__.findOneAndUpdate.call(_this, query, data, options));
        };
      })(this));
    };

    return IllustratorProvider;

  })(BaseProvider);

}).call(this);
