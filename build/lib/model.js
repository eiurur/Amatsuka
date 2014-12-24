(function() {
  var ObjectId, Schema, TL, TLProvider, TLSchema, User, UserProvider, UserSchema, db, mongoose, uri, _;

  mongoose = require('mongoose');

  _ = require('lodash');

  uri = process.env.MONGOHQ_URL || 'mongodb://127.0.0.1/aebs';

  db = mongoose.connect(uri);

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
    createdAt: {
      type: Date,
      "default": Date.now()
    }
  });

  TLSchema = new Schema({
    twitterIdStr: {
      type: String,
      unique: true,
      index: true
    },
    ids: [
      {
        type: String
      }
    ],
    createdAt: {
      type: Date,
      "default": Date.now()
    }
  });

  mongoose.model('User', UserSchema);

  mongoose.model('TL', TLSchema);

  User = mongoose.model('User');

  TL = mongoose.model('TL');

  UserProvider = (function() {
    function UserProvider() {}

    UserProvider.prototype.findUserById = function(params, callback) {
      console.log("\n============> User findUserByID\n");
      console.log(params);
      return User.findOne({
        twitterIdStr: params.twitterIdStr
      }, function(err, user) {
        return callback(err, user);
      });
    };

    UserProvider.prototype.findAllUsers = function(params, callback) {
      console.log("\n============> User findAllUser\n");
      console.log(params);
      return User.find({}, function(err, users) {
        return callback(err, users);
      });
    };

    UserProvider.prototype.upsert = function(params, callback) {
      var user;
      user = void 0;
      console.log("\n============> User upsert\n");
      console.log(params);
      user = {
        twitterIdStr: params.profile._json.id_str,
        name: params.profile.username,
        screenName: params.profile.displayName,
        icon: params.profile._json.profile_image_url_https,
        url: params.profile._json.url,
        accessToken: params.profile.twitter_token,
        accessTokenSecret: params.profile.twitter_token_secret
      };
      return User.update({
        twitterIdStr: params.profile._json.id_str
      }, user, {
        upsert: true
      }, function(err) {
        return callback(err);
      });
    };

    return UserProvider;

  })();

  TLProvider = (function() {
    function TLProvider() {}

    TLProvider.prototype.findOneById = function(params, callback) {
      console.log("\n============> TL findOneByID\n");
      console.log(params);
      return TL.findOne({
        twitterIdStr: params.twitterIdStr
      }, function(err, tl) {
        return callback(err, tl);
      });
    };

    TLProvider.prototype.upsert = function(params, callback) {
      var timeline;
      console.log("\n============> TL upsert\n");
      console.log(params.twitterIdStr);
      timeline = {
        twitterIdStr: params.twitterIdStr,
        ids: params.ids
      };
      return TL.update({
        twitterIdStr: params.twitterIdStr
      }, timeline, {
        upsert: true
      }, function(err) {
        return callback(err);
      });
    };

    return TLProvider;

  })();

  exports.UserProvider = new UserProvider();

  exports.TLProvider = new TLProvider();

}).call(this);
