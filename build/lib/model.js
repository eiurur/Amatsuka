(function() {
  var Config, ConfigProvider, ConfigSchema, Illustrator, IllustratorProvider, IllustratorSchema, ObjectId, Pict, PictProvider, PictSchema, PictTweetSchema, Schema, TL, TLProvider, TLSchema, User, UserProvider, UserSchema, db, mongoose, uri, _;

  mongoose = require('mongoose');

  _ = require('lodash');

  uri = process.env.MONGOHQ_URL || 'mongodb://127.0.0.1/amatsuka';

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
    description: String,
    createdAt: {
      type: Date,
      "default": Date.now()
    }
  });

  PictTweetSchema = new Schema({
    twitterIdStr: String,
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
    pictTweetList: [PictTweetSchema]
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

  ConfigSchema = new Schema({
    twitterIdStr: {
      type: String,
      unique: true,
      index: true
    },
    configStr: String
  });

  mongoose.model('User', UserSchema);

  mongoose.model('Illustrator', IllustratorSchema);

  mongoose.model('Pict', PictSchema);

  mongoose.model('TL', TLSchema);

  mongoose.model('Config', ConfigSchema);

  User = mongoose.model('User');

  Illustrator = mongoose.model('Illustrator');

  Pict = mongoose.model('Pict');

  TL = mongoose.model('TL');

  Config = mongoose.model('Config');

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

    UserProvider.prototype.findOneAndUpdate = function(params, callback) {
      var user;
      user = null;
      console.log("\n============> User upsert\n");
      console.log(params);
      user = params.user;
      return User.findOneAndUpdate({
        twitterIdStr: params.user.twitterIdStr
      }, user, {
        upsert: true
      }, function(err, user) {
        return callback(err, user);
      });
    };

    return UserProvider;

  })();

  IllustratorProvider = (function() {
    function IllustratorProvider() {}

    IllustratorProvider.prototype.findById = function(params, callback) {
      console.log("\n============> Illustrator findUserByID\n");
      console.log(params);
      return Illustrator.findOne({
        twitterIdStr: params.twitterIdStr
      }, function(err, user) {
        return callback(err, user);
      });
    };

    IllustratorProvider.prototype.findOneAndUpdate = function(params, callback) {
      var illustrator;
      illustrator = null;
      console.log("\n============> Illustrator upsert\n");
      console.log(params);
      illustrator = params.illustrator;
      return Illustrator.findOneAndUpdate({
        twitterIdStr: params.illustrator.twitterIdStr
      }, illustrator, {
        upsert: true
      }, function(err, illustrator) {
        return callback(err, illustrator);
      });
    };

    return IllustratorProvider;

  })();

  PictProvider = (function() {
    function PictProvider() {}

    PictProvider.prototype.find = function(params, callback) {
      console.log("\n============> Pict find\n");
      console.log(params);
      return Pict.find({}).limit(params.limit || 20).skip(params.skip || 0).sort({
        updatedAt: -1
      }).populate('postedBy').exec(function(err, pics) {
        console.timeEnd('Pict find');
        return callback(err, pics);
      });
    };

    PictProvider.prototype.findOneAndUpdate = function(params) {
      return new Promise(function(resolve, reject) {
        var pict;
        pict = null;
        console.log("\n============> Pict upsert\n");
        console.log(params);
        pict = params;
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

    return PictProvider;

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

  ConfigProvider = (function() {
    function ConfigProvider() {}

    ConfigProvider.prototype.findOneById = function(params, callback) {
      console.log("\n============> Config findOneByID\n");
      console.log(params);
      return Config.findOne({
        twitterIdStr: params.twitterIdStr
      }, function(err, config) {
        return callback(err, config);
      });
    };

    ConfigProvider.prototype.upsert = function(params, callback) {
      var config;
      console.log("\n============> Config upsert\n");
      console.log(params);
      config = {
        twitterIdStr: params.twitterIdStr,
        configStr: JSON.stringify(params.config)
      };
      return Config.update({
        twitterIdStr: params.twitterIdStr
      }, config, {
        upsert: true
      }, function(err) {
        return callback(err);
      });
    };

    ConfigProvider.prototype.findOneAndUpdate = function(params, callback) {
      var config;
      console.log("\n============> User findOneAndUpdate\n");
      console.log(params);
      config = {
        twitterIdStr: params.twitterIdStr,
        configStr: JSON.stringify(params.config)
      };
      return Config.findOneAndUpdate({
        twitterIdStr: params.twitterIdStr
      }, config, {
        upsert: true
      }, function(err, config) {
        return callback(err, config);
      });
    };

    return ConfigProvider;

  })();

  exports.UserProvider = new UserProvider();

  exports.IllustratorProvider = new IllustratorProvider();

  exports.PictProvider = new PictProvider();

  exports.TLProvider = new TLProvider();

  exports.ConfigProvider = new ConfigProvider();

}).call(this);
