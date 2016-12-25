(function() {
  var BaseProvider, ObjectId, Schema, User, UserProvider, UserSchema, mongoose,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  mongoose = require('mongoose');

  BaseProvider = require('./BaseProvider');

  Schema = mongoose.Schema;

  ObjectId = Schema.ObjectId;

  UserSchema = new Schema({
    twitterIdStr: {
      type: String,
      unique: true,
      index: true
    },
    name: String,
    screenName: String,
    icon: String,
    url: String,
    accessToken: String,
    accessTokenSecret: String,
    maoToken: String,
    createdAt: {
      type: Date,
      "default": Date.now()
    },
    updatedAt: {
      type: Date,
      "default": Date.now()
    }
  });

  mongoose.model('User', UserSchema);

  User = mongoose.model('User');

  module.exports = UserProvider = (function(superClass) {
    extend(UserProvider, superClass);

    function UserProvider() {
      UserProvider.__super__.constructor.call(this, User);
    }

    UserProvider.prototype.findOneAndUpdate = function(params, callback) {
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

    return UserProvider;

  })(BaseProvider);

}).call(this);
