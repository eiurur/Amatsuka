(function() {
  var crypto, moment, my, util, _;

  _ = require('lodash');

  util = require('util');

  moment = require('moment');

  crypto = require('crypto');

  my = function() {
    return {
      c: function(desciption, str) {
        desciption = desciption || '';
        str = str || '';
        return console.log("" + desciption + ": " + str);
      },
      e: function(desciption, str) {
        desciption = desciption || '';
        str = str || '';
        return console.error("" + desciption + ": " + str);
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
          var _results;
          _results = [];
          for (k in params) {
            v = params[k];
            _results.push("" + k + "=" + v);
          }
          return _results;
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
      createUID: function(size, base) {
        var buf, i, len;
        size = size || 32;
        base = base || "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        len = base.length;
        buf = [];
        i = 0;
        while (i < size) {
          buf.push(base[Math.floor(Math.random() * len)]);
          ++i;
        }
        return buf.join("");
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
      }
    };
  };

  exports.my = my();

}).call(this);
