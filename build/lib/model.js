(function() {
  var Config, ConfigProvider, ConfigSchema, Illustrator, IllustratorProvider, IllustratorSchema, ObjectId, Pict, PictProvider, PictSchema, PictTweetSchema, Schema, TL, TLProvider, TLSchema, User, UserProvider, UserSchema, _, db, mongoose, uri;

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
    maoToken: String,
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
    },
    updatedAt: {
      type: Date,
      "default": Date.now()
    }
  });

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

  IllustratorSchema.index({
    twitterIdStr: 1
  });

  PictSchema.index({
    twitterIdStr: 1,
    updatedAt: -1
  });

  User = mongoose.model('User');

  Illustrator = mongoose.model('Illustrator');

  Pict = mongoose.model('Pict');

  TL = mongoose.model('TL');

  Config = mongoose.model('Config');

  UserProvider = (function() {
    function UserProvider() {}

    UserProvider.prototype.findUserById = function(params, callback) {
      console.log("\n============> User findUserByID\n");
      return User.findOne({
        twitterIdStr: params.twitterIdStr
      }, function(err, user) {
        return callback(err, user);
      });
    };

    UserProvider.prototype.findAllUsers = function(params, callback) {
      console.log("\n============> User findAllUser\n");
      return User.find({}, function(err, users) {
        return callback(err, users);
      });
    };

    UserProvider.prototype.findOneAndUpdate = function(params, callback) {
      var user;
      user = null;
      console.log("\n============> User upsert\n");
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

    IllustratorProvider.prototype.find = function(params, callback) {
      return new Promise(function(resolve, reject) {
        console.log("\n============> Illustrator find\n");
        console.time('Illustrator find');
        return Illustrator.find({}).sort({
          updatedAt: -1
        }).exec(function(err, illustratorList) {
          console.timeEnd('Illustrator find');
          if (err) {
            return reject(err);
          }
          return resolve(illustratorList);
        });
      });
    };

    IllustratorProvider.prototype.findById = function(params, callback) {
      return new Promise(function(resolve, reject) {
        console.log("\n============> Illustrator findUserByID\n");
        console.log(params);
        return Illustrator.findOne({
          twitterIdStr: params.twitterIdStr
        }, function(err, user) {
          if (err) {
            return reject(err);
          }
          return resolve(user);
        });
      });
    };

    IllustratorProvider.prototype.findOneAndUpdate = function(params, callback) {
      var illustrator;
      illustrator = null;
      console.log("\n============> Illustrator upsert\n");
      illustrator = params.illustrator;
      illustrator.updatedAt = Date.now();
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

    PictProvider.prototype.findByIllustratorObjectId = function(params, callback) {
      return new Promise(function(resolve, reject) {
        console.log("\n============> Pict findByIllustratorObjectId\n");
        console.time('Pict findByIllustratorObjectId');
        return Pict.find({
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

  })();

  TLProvider = (function() {
    function TLProvider() {}

    TLProvider.prototype.findOneById = function(params, callback) {
      console.log("\n============> TL findOneByID\n");
      return TL.findOne({
        twitterIdStr: params.twitterIdStr
      }, function(err, tl) {
        return callback(err, tl);
      });
    };

    TLProvider.prototype.upsert = function(params, callback) {
      var timeline;
      console.log("\n============> TL upsert\n");
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
      return Config.findOne({
        twitterIdStr: params.twitterIdStr
      }, function(err, config) {
        return callback(err, config);
      });
    };

    ConfigProvider.prototype.upsert = function(params, callback) {
      var config;
      console.log("\n============> Config upsert\n");
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
