(function() {
  var BaseProvider, Config, ConfigProvider, ConfigSchema, ObjectId, Schema, mongoose,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  mongoose = require('mongoose');

  BaseProvider = require('./BaseProvider');

  Schema = mongoose.Schema;

  ObjectId = Schema.ObjectId;

  ConfigSchema = new Schema({
    twitterIdStr: {
      type: String,
      unique: true,
      index: true
    },
    configStr: String
  });

  mongoose.model('Config', ConfigSchema);

  Config = mongoose.model('Config');

  module.exports = ConfigProvider = (function(superClass) {
    extend(ConfigProvider, superClass);

    function ConfigProvider() {
      ConfigProvider.__super__.constructor.call(this, Config);
    }

    ConfigProvider.prototype.findOneById = function(params, callback) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          var opts;
          console.time('Config findOneById');
          opts = {
            twitterIdStr: params.twitterIdStr
          };
          return Config.findOne(opts).exec(function(err, config) {
            console.timeEnd('Config findOneById');
            if (err) {
              return reject(err);
            }
            return resolve(config);
          });
        };
      })(this));
    };

    ConfigProvider.prototype.upsert = function(params) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          var data, options, query;
          console.log(params);
          query = {
            twitterIdStr: params.twitterIdStr
          };
          data = {
            twitterIdStr: params.twitterIdStr,
            configStr: JSON.stringify(params.config)
          };
          options = {
            'new': true,
            upsert: true
          };
          return resolve(_this.update(query, data, options));
        };
      })(this));
    };

    ConfigProvider.prototype.findOneAndUpdate = function(params) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          var data, options, query;
          console.log(params);
          query = {
            twitterIdStr: params.twitterIdStr
          };
          data = {
            twitterIdStr: params.twitterIdStr,
            configStr: JSON.stringify(params.config)
          };
          options = {
            'new': true,
            upsert: true
          };
          return resolve(ConfigProvider.__super__.findOneAndUpdate.call(_this, query, data, options));
        };
      })(this));
    };

    return ConfigProvider;

  })(BaseProvider);

}).call(this);
