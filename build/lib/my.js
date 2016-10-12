(function() {
  var Promise, _, atob, crypto, moment, my, request, util;

  _ = require('lodash');

  util = require('util');

  atob = require('atob');

  moment = require('moment');

  crypto = require('crypto');

  request = require('request');

  Promise = require('bluebird');

  my = function() {
    return {
      c: function(desciption, str) {
        desciption = desciption || '';
        str = str || '';
        return console.log(desciption + ": " + str);
      },
      e: function(desciption, str) {
        desciption = desciption || '';
        str = str || '';
        return console.error(desciption + ": " + str);
      },
      dump: function(obj) {
        return console.log(util.inspect(obj, false, null));
      },
      include: function(array, str) {
        return !array.every(function(elem, idx, array) {
          return str.indexOf(elem) === -1;
        });
      },
      createParams: function(params) {
        var k, v;
        return ((function() {
          var results;
          results = [];
          for (k in params) {
            v = params[k];
            results.push(k + "=" + v);
          }
          return results;
        })()).join('&');
      },
      formatX: function(time) {
        if (time != null) {
          return moment(time).format("X");
        } else {
          return moment().format("X");
        }
      },
      formatYMD: function(time) {
        if (time != null) {
          return moment(new Date(time)).format("YYYY-MM-DD");
        } else {
          return moment().format("YYYY-MM-DD");
        }
      },
      formatYMDHms: function(time) {
        if (time != null) {
          return moment(new Date(time)).format("YYYY-MM-DD HH:mm:ss");
        } else {
          return moment().format("YYYY-MM-DD HH:mm:ss");
        }
      },
      addSecondsFormatYMDHms: function(seconds, time) {
        if (time != null) {
          return moment(new Date(time)).add(seconds, 's').format("YYYY-MM-DD HH:mm:ss");
        } else {
          return moment().add(seconds, 's').format("YYYY-MM-DD HH:mm:ss");
        }
      },
      endBrinkFormatYMDHms: function(time) {
        if (time != null) {
          return moment(time + " 23:59:59").format("YYYY-MM-DD HH:mm:ss");
        }
      },
      rigthAfterStartingFormatYMDHms: function(time) {
        if (time != null) {
          return moment(time + " 00:00:00").format("YYYY-MM-DD HH:mm:ss");
        }
      },
      isSameDay: function(startTimeYMD, endTimeYMD) {
        if (startTimeYMD === endTimeYMD) {
          return true;
        } else {
          return false;
        }
      },
      createHash: function(key, algorithm) {
        algorithm = algorithm || "sha256";
        return crypto.createHash(algorithm).update(key).digest("hex");
      },
      random: function(array) {
        return array[Math.floor(Math.random() * array.length)];
      },
      randomByLimitNum: function(array, num) {
        var pluckedVal, result;
        result = [];
        if (array.length < num) {
          result = [].concat(array);
          console.log("num =  " + num + " array = " + array.length + ", result = " + result.length);
          return result;
        }
        while (result.length < num) {
          pluckedVal = this.random(array);
          if (_.contains(result, pluckedVal)) {
            continue;
          }
          result.push(pluckedVal);
        }
        return result;
      },
      decStrNum: function(n) {
        var i, result;
        n = n.toString();
        result = n;
        i = n.length - 1;
        while (i > -1) {
          if (n[i] === '0') {
            result = result.substring(0, i) + '9' + result.substring(i + 1);
            i -= 1;
          } else {
            result = result.substring(0, i) + (parseInt(n[i], 10) - 1).toString() + result.substring(i + 1);
            return result;
          }
        }
        return result;
      },
      loadBase64Data: function(url) {
        return new Promise(function(resolve, reject) {
          return request({
            url: url,
            encoding: null
          }, function(err, res, body) {
            var base64prefix, image;
            if (err || res.statusCode !== 200) {
              return reject(err);
            }
            base64prefix = 'data:' + res.headers['content-type'] + ';base64,';
            image = body.toString('base64');
            return resolve(base64prefix + image);
          });
        });
      },
      promiseWhile: function(condition, action) {
        return new Promise(function(resolve, reject) {
          var loop_;
          loop_ = function() {
            if (!condition()) {
              return resolve();
            }
            return Promise.cast(action()).then(loop_)["catch"](reject);
          };
          return process.nextTick(loop_);
        });
      },
      delayPromise: function(ms) {
        return new Promise(function(resolve) {
          return setTimeout(resolve, ms);
        });
      }
    };
  };

  exports.my = my();

}).call(this);
