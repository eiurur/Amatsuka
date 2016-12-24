(function() {
  var BaseProvider, _, chalk, db, moment, mongoose, path, settings, uri;

  path = require('path');

  _ = require('lodash');

  chalk = require('chalk');

  moment = require('moment');

  mongoose = require('mongoose');

  settings = require(path.resolve('build', 'lib', 'configs', 'settings')).settings;

  uri = process.env.MONGOLAB_URI || settings.MONGODB_URI;

  db = mongoose.connect(uri);

  module.exports = BaseProvider = (function() {
    function BaseProvider(Model) {
      this.Model = Model;
      console.log(this.Model.modelName);
    }

    BaseProvider.prototype.aggregate = function(query) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          console.log("\n============> " + _this.Model.modelName + " aggregate\n");
          console.log(query);
          console.time(_this.Model.modelName + " aggregate");
          return _this.Model.aggregate(query).exec(function(err, result) {
            console.timeEnd(_this.Model.modelName + " aggregate");
            if (err) {
              return reject(err);
            }
            return resolve(result);
          });
        };
      })(this));
    };

    BaseProvider.prototype.count = function(query) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          console.log("\n============> " + _this.Model.modelName + " count\n");
          console.log(query);
          console.time(_this.Model.modelName + " count");
          return _this.Model.count(query).exec(function(err, posts) {
            console.timeEnd(_this.Model.modelName + " count");
            if (err) {
              return reject(err);
            }
            return resolve(posts);
          });
        };
      })(this));
    };

    BaseProvider.prototype.findByIdAndUpdate = function(_id, data, options) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          console.log(chalk.green("DBBaseProvider " + _this.Model.modelName + " findByIdAndUpdate"));
          console.log(_id);
          console.log(data);
          console.log(options);
          console.time(_this.Model.modelName + " findByIdAndUpdate");
          return _this.Model.findByIdAndUpdate(_id, data, options, function(err, doc) {
            console.timeEnd(_this.Model.modelName + " findByIdAndUpdate");
            if (err) {
              return reject(err);
            }
            return resolve(doc);
          });
        };
      })(this));
    };

    BaseProvider.prototype.findOneAndUpdate = function(query, data, options) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          console.log(chalk.green("DBBaseProvider " + _this.Model.modelName + " findOneAndUpdate"));
          console.log(query);
          console.log(data);
          console.log(options);
          console.time(_this.Model.modelName + " findOneAndUpdate");
          return _this.Model.findOneAndUpdate(query, data, options, function(err, doc) {
            console.timeEnd(_this.Model.modelName + " findOneAndUpdate");
            if (err) {
              return reject(err);
            }
            return resolve(doc);
          });
        };
      })(this));
    };

    BaseProvider.prototype.save = function(data) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          console.log(chalk.green("DBBaseProvider " + _this.Model.modelName + " save"));
          console.time(_this.Model.modelName + " save");
          return data.save(function(err, doc) {
            console.timeEnd(_this.Model.modelName + " save");
            if (err) {
              return reject(err);
            }
            return resolve(doc);
          });
        };
      })(this));
    };

    BaseProvider.prototype.update = function(query, data, options) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          console.log(chalk.green("DBBaseProvider " + _this.Model.modelName + " update"));
          console.log(query);
          console.log(data);
          console.log(options);
          console.time(_this.Model.modelName + " update");
          return _this.Model.update(query, data, options, function(err) {
            console.timeEnd(_this.Model.modelName + " update");
            if (err) {
              return reject(err);
            }
            return resolve('update ok');
          });
        };
      })(this));
    };

    BaseProvider.prototype.remove = function(query, data, options) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          console.log(chalk.green("DBBaseProvider " + _this.Model.modelName + " remove"));
          console.log(query);
          console.log(data);
          console.log(options);
          console.time(_this.Model.modelName + " remove");
          return _this.Model.remove(query, function(err) {
            console.timeEnd(_this.Model.modelName + " remove");
            if (err) {
              return reject(err);
            }
            return resolve('remove ok');
          });
        };
      })(this));
    };

    return BaseProvider;

  })();

}).call(this);
