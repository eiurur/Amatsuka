angular.module('myApp', ['ngRoute', 'ngAnimate', 'ngSanitize', 'infinite-scroll', 'myApp.controllers', 'myApp.filters', 'myApp.services', 'myApp.factories', 'myApp.directives']).constant('utils', {
  'devices': {
    '0': 'PC',
    '1': 'Smart Phone',
    '2': 'Tablet',
    '3': 'Fablet',
    '4': 'Smart Watch'
  }
}).run(["$rootScope", "utils", function($rootScope, utils) {
  return $rootScope.utils = utils;
}]).config(["$routeProvider", "$locationProvider", function($routeProvider, $locationProvider) {
  $routeProvider.when('/', {
    templateUrl: 'partials/index',
    controller: 'IndexCtrl'
  }).when('/member', {
    templateUrl: 'partials/member',
    controller: 'MemberCtrl'
  }).when("/logout", {
    redirectTo: "/"
  }).when("http://127.0.0.1:4040/auth/twitter/callback", {
    redirectTo: "/"
  });
  return $locationProvider.html5Mode(true);
}]);


/*
Logの拡張
 */
var i, methods, _fn;

methods = ["log", "warn", "error", "info", "debug", "dir"];

_fn = function(m) {
  if (console[m]) {
    window[m] = console[m].bind(console);
  } else {
    window[m] = log;
  }
};
for (i in methods) {
  _fn(methods[i]);
}

angular.module("myApp.controllers", []).controller('CommonCtrl', ["$location", "$log", "$rootScope", "$scope", function($location, $log, $rootScope, $scope) {
  return $rootScope.$on('$locationChangeStart', function(event, next, current) {
    $log.info('location changin to: ' + next);
  });
}]);

angular.module("myApp.directives", []).directive('boxLoading', ["$interval", function($interval) {
  return {
    restrict: 'E',
    link: function(scope, element, attrs) {
      var allocations, animate, count, rotate, tag;
      tag = '<div class="loader-12day">\n  <b></b>\n  <b></b>\n  <b></b>\n  <b></b>\n  <b></b>\n  <b></b>\n  <b></b>\n  <b></b>\n  <b></b>\n</div>';
      element.append(tag);
      count = 0;
      allocations = [0, 1, 2, 5, 8, 7, 6, 3];
      rotate = function() {
        var bs;
        bs = element.find('b');
        _.map(bs, function(elem) {
          return elem.style.background = 'black';
        });
        bs[allocations[count]].style.background = 'white';
        count++;
        if (count === 8) {
          return count = 0;
        }
      };
      return animate = $interval(rotate, 150);
    }
  };
}]).directive("slideable", function() {
  return {
    restrict: "C",
    compile: function(element, attr) {
      var contents, postLink;
      contents = element.html();
      element.html("<div class='slideable_content'\n  style='margin:0 !important; padding:0 !important'>\n  " + contents + "\n</div>");
      postLink = function(scope, element, attrs) {
        console.log(attrs);
        attrs.duration = !attrs.duration ? "0.4s" : attrs.duration;
        attrs.easing = !attrs.easing ? "ease-in-out" : attrs.easing;
        return element.css({
          overflow: "hidden",
          height: "0px",
          transitionProperty: "height",
          transitionDuration: attrs.duration,
          transitionTimingFunction: attrs.easing
        });
      };
    }
  };
}).directive("slideToggle", function() {
  return {
    restrict: "A",
    link: function(scope, element, attrs) {
      var content, target;
      target = void 0;
      content = void 0;
      attrs.expanded = false;
      return element.bind("click", function() {
        var y;
        if (!target) {
          target = document.querySelector(attrs.slideToggle);
        }
        if (!content) {
          content = target.querySelector(".slideable_content");
        }
        if (!attrs.expanded) {
          content.style.border = "1px solid rgba(0,0,0,0)";
          y = content.clientHeight;
          content.style.border = 0;
          target.style.height = y + "px";
        } else {
          target.style.height = "0px";
        }
        return attrs.expanded = !attrs.expanded;
      });
    }
  };
}).directive("imgPreload", ["$rootScope", function($rootScope) {
  return {
    restrict: "A",
    scope: {
      ngSrc: "@"
    },
    link: function(scope, element, attrs) {
      return element.on("load", function() {
        return element.addClass("in");
      }).on("error", function() {});
    }
  };
}]).directive("scrollOnClick", function() {
  return {
    restrict: "A",
    scope: {
      scrollTo: "@"
    },
    link: function(scope, element, attrs) {
      return element.on('click', function() {
        return $('html, body').animate({
          scrollTop: $(scope.scrollTo).offset().top
        }, "slow");
      });
    }
  };
});

angular.module("myApp.factories", []).factory('Tweets', ["$http", "TweetService", function($http, TweetService) {
  var Tweets;
  Tweets = (function() {
    function Tweets(items, list, maxId) {
      this.busy = false;
      this.isLast　 = false;
      this.items = items;
      this.list = list;
      this.maxId = maxId;
    }

    Tweets.prototype.nextPage = function() {
      console.log(this.busy);
      console.log(this.isLast);
      if (this.busy || this.isLast) {
        return;
      }
      this.busy = true;
      return TweetService.getListsStatuses({
        listIdStr: this.list.id_str,
        maxId: this.maxId,
        count: 100
      }).then((function(_this) {
        return function(data) {
          var items, itemsNomalized;
          console.table(data.data);
          if (_.isEmpty(data.data)) {
            _this.isLast = true;
            _this.busy = false;
            return;
          }
          _this.maxId = TweetService.decStrNum(_.last(data.data).id_str);
          items = TweetService.filterIncludeImage(data.data);
          itemsNomalized = TweetService.nomalize(items);
          _this.items = _this.items.concat(itemsNomalized);
          return _this.busy = false;
        };
      })(this));
    };

    return Tweets;

  })();
  return Tweets;
}]);

angular.module("myApp.filters", []).filter("interpolate", ["version", function(version) {
  return function(text) {
    return String(text).replace(/\%VERSION\%/g, version);
  };
}]).filter("noHTML", function() {
  return function(text) {
    if (text != null) {
      return text.replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/&/, '&amp;');
    }
  };
}).filter('newlines', ["$sce", function($sce) {
  return function(text) {
    return $sce.trustAsHtml(text != null ? text.replace(/\n/g, '<br />') : '');
  };
}]);

angular.module("myApp.services", []).service("CommonService", function() {
  return {
    isLoaded: false
  };
});

angular.module("myApp.controllers").controller("MemberCtrl", ["$scope", "$log", "AuthService", "TweetService", "Tweets", function($scope, $log, AuthService, TweetService, Tweets) {
  var amatsukaList, maxId;
  if (_.isEmpty(AuthService.user)) {
    return;
  }
  console.log('Member AuthService.user = ', AuthService.user);
  maxId = maxId || 0;
  amatsukaList = {};
  console.time('getListsList');
  return TweetService.getListsList().then(function(data) {
    amatsukaList = _.findWhere(data.data, {
      'name': 'Amatsuka'
    });
    $scope.listIdStr = amatsukaList.id_str;
    console.timeEnd('getListsList');
    console.time('getListsMembers');
    return TweetService.getListsMembers({
      listIdStr: amatsukaList.id_str
    });
  }).then(function(data) {
    var membersNormalized;
    console.table(data.data.users);
    membersNormalized = TweetService.nomarlizeMembers(data.data.users);
    $scope.amatsukaMemberList = membersNormalized;
    return console.timeEnd('getListsMembers');
  });
}]);

angular.module("myApp.controllers").controller("AdminUserCtrl", ["$scope", "$rootScope", "$log", "AuthService", function($scope, $rootScope, $log, AuthService) {
  $scope.isLoaded = false;
  $scope.isAuthenticated = AuthService.status.isAuthenticated;
  if (AuthService.status.isAuthenticated) {
    $scope.isLoaded = true;
    return;
  }
  return AuthService.isAuthenticated().success(function(data) {
    if (_.isNull(data.data)) {
      $scope.isLoaded = true;
      return;
    }
    AuthService.status.isAuthenticated = true;
    $scope.isAuthenticated = AuthService.status.isAuthenticated;
    AuthService.user = data.data;
    $scope.user = data.data;
    return $scope.isLoaded = true;
  }).error(function(status, data) {
    console.log(status);
    return console.log(data);
  });
}]);

angular.module("myApp.controllers").controller("IndexCtrl", ["$scope", "$log", "AuthService", "TweetService", "Tweets", function($scope, $log, AuthService, TweetService, Tweets) {
  var amatsukaFollowList, amatsukaList, maxId;
  if (_.isEmpty(AuthService.user)) {
    return;
  }
  console.log('Index AuthService.user = ', AuthService.user);
  maxId = maxId || 0;
  amatsukaList = {};
  amatsukaFollowList = [];
  console.time('getListsList');
  TweetService.getListsList().then(function(data) {
    amatsukaList = _.findWhere(data.data, {
      'name': 'Amatsuka'
    });
    $scope.listIdStr = amatsukaList.id_str;
    console.timeEnd('getListsList');
    console.time('getListsMembers');
    return TweetService.getListsMembers({
      listIdStr: amatsukaList.id_str
    });
  }).then(function(data) {
    console.table(data.data.users);
    amatsukaFollowList = data.data.users;
    console.timeEnd('getListsMembers');
    return TweetService.getListsStatuses({
      listIdStr: amatsukaList.id_str,
      maxId: maxId,
      count: 20
    });
  }).then(function(data) {
    var tweets, tweetsNomalized;
    console.time('newTweets');
    maxId = TweetService.decStrNum(_.last(data.data).id_str);
    tweets = TweetService.filterIncludeImage(data.data);
    console.log(amatsukaList);
    console.log(amatsukaFollowList);
    tweetsNomalized = TweetService.nomalize(tweets, amatsukaFollowList);
    $scope.tweets = new Tweets(tweetsNomalized, amatsukaList, maxId);
    return console.timeEnd('newTweets');
  });
  return $scope.$on('newTweet', function(event, args) {
    var newTweets, tweetsNomalized;
    console.log('newTweet on ', args);
    newTweets = TweetService.filterIncludeImage(args);
    console.table(newTweets);
    tweetsNomalized = TweetService.nomalize(newTweets, amatsukaFollowList);
    return $scope.tweets.items = _.uniq(_.union($scope.tweets.items, tweetsNomalized), 'id_str');
  });
}]);

angular.module("myApp.directives").directive("appVersion", ["version", function(version) {
  return function(scope, elm, attrs) {
    elm.text(version);
  };
}]);

angular.module("myApp.directives").directive('favoritable', ["TweetService", function(TweetService) {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      return element.on('click', function(event) {
        return TweetService.createFavorite(attrs.tweetIdStr).success(function(data) {
          if (data.data === null) {

          } else {

          }
        }).error(function(status, data) {
          console.log(status);
          return console.log(data);
        });
      });
    }
  };
}]).directive('retweetable', ["TweetService", function(TweetService) {
  return {
    restrict: 'A',
    scope: {
      num: '='
    },
    link: function(scope, element, attrs) {
      return element.on('click', function(event) {
        if (!window.confirm('リツイートしてもよろしいですか？')) {
          return;
        }
        return TweetService.statusesRetweet(attrs.tweetIdStr).success(function(data) {
          if (data.data === null) {

          } else {
            return console.log(data.data.entities.media[0].media_url);
          }
        });
      });
    }
  };
}]).directive('followable', ["TweetService", function(TweetService) {
  return {
    restrict: 'E',
    replace: true,
    scope: {
      listIdStr: '@',
      twitterIdStr: '@',
      followStatus: '='
    },
    template: '<span class="label label-default timeline__post--header--label">{{content}}</span>',
    link: function(scope, element, attrs) {
      if (scope.followStatus === false) {
        scope.content = '+';
      }
      element.on('mouseover', function(e) {
        scope.content = 'フォロー';
        return scope.$apply();
      });
      element.on('mouseout', function(e) {
        scope.content = '+';
        return scope.$apply();
      });
      return element.on('click', function() {
        console.log(scope.listIdStr);
        console.log(scope.twitterIdStr);
        if (scope.followStatus === false) {
          scope.content = 'ok ...';
          return TweetService.createListsMembers({
            listIdStr: scope.listIdStr,
            twitterIdStr: scope.twitterIdStr
          }).then(function(data) {
            return element.fadeOut(200);
          });
        }
      });
    }
  };
}]).directive('followable', ["TweetService", function(TweetService) {
  return {
    restrict: 'A',
    scope: {
      listIdStr: '@',
      twitterIdStr: '@',
      followStatus: '='
    },
    link: function(scope, element, attrs) {
      console.log(element);
      console.log(scope.followStatus);
      element[0].innerText = scope.followStatus ? 'フォロー解除' : 'フォロー';
      return element.on('click', function() {
        console.log(scope.listIdStr);
        console.log(scope.twitterIdStr);
        scope.isProcessing = true;
        if (scope.followStatus === true) {
          TweetService.destroyListsMembers({
            listIdStr: scope.listIdStr,
            twitterIdStr: scope.twitterIdStr
          }).then(function(data) {
            element[0].innerText = 'フォロー';
            return scope.isProcessing = false;
          });
        }
        if (scope.followStatus === false) {
          TweetService.createListsMembers({
            listIdStr: scope.listIdStr,
            twitterIdStr: scope.twitterIdStr
          }).then(function(data) {
            element[0].innerText = 'フォロー解除';
            return scope.isProcessing = false;
          });
        }
        return scope.followStatus = !scope.followStatus;
      });
    }
  };
}]).directive('newTweetLoad', ["$rootScope", "TweetService", function($rootScope, TweetService) {
  return {
    restrict: 'E',
    scope: {
      listIdStr: '@'
    },
    template: '<a class="btn" ng-disabled="isProcessing">{{text}}</a>',
    link: function(scope, element, attrs) {
      scope.text = '新着を読み込む';
      return element.on('click', function() {
        scope.isProcessing = true;
        return TweetService.getListsStatuses({
          listIdStr: scope.listIdStr,
          count: 50
        }).then(function(data) {
          console.log('getListsStatuses', data.data);
          $rootScope.$broadcast('newTweet', data.data);
          scope.text = '新着を読み込む';
          return scope.isProcessing = false;
        });
      });
    }
  };
}]);

angular.module("myApp.services").service("AuthService", ["$http", function($http) {
  return {
    findUserById: function(twitterIdStr) {
      return $http.post("/api/findUserById", twitterIdStr);
    },
    isAuthenticated: function() {
      return $http.get("/api/isAuthenticated");
    },
    status: {
      isAuthenticated: false
    },
    user: {}
  };
}]);

angular.module("myApp.services").service("TweetService", ["$http", "$q", function($http, $q) {
  return {
    activateLink: function(t) {
      return t.replace(/((ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&amp;%@!&#45;\/]))?)/g, "<a href=\"$1\" target=\"_blank\">$1</a>").replace(/(^|\s)(@|＠)(\w+)/g, "$1<a href=\"http://www.twitter.com/$3\" target=\"_blank\">@$3</a>").replace(/(?:^|[^ーー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9&_\/>]+)[#＃]([ー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9_]*[ー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z]+[ー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9_]*)/g, ' <a href="http://twitter.com/search?q=%23$1" target="_blank">#$1</a>');
    },
    iconBigger: function(url) {
      if (_.isUndefined(url)) {
        return this.replace('normal', 'bigger');
      }
      return url.replace('normal', 'bigger');
    },
    isFollow: function(tweet, userList) {
      return !_.isUndefined(_.findWhere(userList, {
        'id_str': tweet.retweeted_status.user.id_str
      }));
    },
    nomalize: function(tweets, list) {
      return _.each(tweets, (function(_this) {
        return function(tweet) {
          var isRT;
          isRT = _.has(tweet, 'retweeted_status');
          if (isRT) {
            tweet.followStatus = _this.isFollow(tweet, list);
            console.log(tweet.retweeted_status.user.id_str);
            console.log(tweet.followStatus);
          }
          tweet.text = _this.activateLink(tweet.text);
          tweet.time = _this.fromNow(_this.get(tweet, 'tweet.created_at', false));
          tweet.retweetNum = _this.get(tweet, 'tweet.retweet_count', isRT);
          tweet.favNum = _this.get(tweet, 'tweet.favorite_count', isRT);
          tweet.tweetIdStr = _this.get(tweet, 'tweet.id_str', isRT);
          tweet.sourceUrl = _this.get(tweet, 'display_url', isRT);
          tweet.picOrigUrl = _this.get(tweet, 'media_url:orig', isRT);
          return tweet.user.profile_image_url = _this.iconBigger(tweet.user.profile_image_url);
        };
      })(this));
    },
    nomarlizeMembers: function(members) {
      return _.each(members, (function(_this) {
        return function(member) {
          member.followStatus = true;
          member.description = _this.activateLink(member.description);
          return member.profile_image_url = _this.iconBigger(member.profile_image_url);
        };
      })(this));
    },
    get: function(tweet, key, isRT) {
      var t, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8;
      t = isRT ? tweet.retweeted_status : tweet;
      switch (key) {
        case 'description':
          return t.user.description;
        case 'display_url':
          return (_ref = t.entities) != null ? (_ref1 = _ref.media) != null ? _ref1[0].display_url : void 0 : void 0;
        case 'entities':
          return t.entities;
        case 'expanded_url':
          return (_ref2 = t.entities) != null ? (_ref3 = _ref2.media) != null ? _ref3[0].expanded_url : void 0 : void 0;
        case 'followers_count':
          return t.user.followers_count;
        case 'friends_count':
          return t.user.friends_count;
        case 'hashtags':
          return (_ref4 = t.entities) != null ? _ref4.hashtags : void 0;
        case 'media_url':
          return (_ref5 = t.entities) != null ? (_ref6 = _ref5.media) != null ? _ref6[0].media_url : void 0 : void 0;
        case 'media_url:orig':
          return ((_ref7 = t.entities) != null ? (_ref8 = _ref7.media) != null ? _ref8[0].media_url : void 0 : void 0) + ':orig';
        case 'name':
          return t.user.name;
        case 'profile_banner_url':
          return t.user.profile_banner_url;
        case 'profile_image_url':
          return t.user.profile_image_url;
        case 'statuses_count':
          return t.user.statuses_count;
        case 'screen_name':
          return t.user.screen_name;
        case 'source':
          return t.source;
        case 'text':
          return t.text;
        case 'timestamp_ms':
          return t.timestamp_ms;
        case 'tweet.created_at':
          return t.created_at;
        case 'tweet.favorite_count':
          return t.favorite_count;
        case 'tweet.retweet_count':
          return t.retweet_count;
        case 'tweet.id_str':
          return t.id_str;
        case 'tweet.lang':
          return t.lang;
        case 'user.created_at':
          return t.user.created_at;
        case 'user.id_str':
          return t.user.id_str;
        case 'user.favorite_count':
          return t.favorite_count;
        case 'user.retweet_count':
          return t.retweet_count;
        case 'user.lang':
          return t.user.lang;
        case 'user.url':
          return t.user.url;
        default:
          return null;
      }
    },
    decStrNum: function(n) {
      var i, result;
      n = n.toString();
      result = n;
      i = n.length - 1;
      while (i > -1) {
        if (n[i] === '0') {
          result = result.substring(0, i) + '9' + result.substring(i + 1);
          i--;
        } else {
          result = result.substring(0, i) + (parseInt(n[i], 10) - 1).toString() + result.substring(i + 1);
          return result;
        }
      }
      return result;
    },
    fromNow: function(time) {
      return moment(time).fromNow(true);
    },
    filterIncludeImage: function(tweets) {
      return _.filter(tweets, function(tweet) {
        return _.has(tweet, 'extended_entities') && !_.isEmpty(tweet.extended_entities.media);
      });
    },
    twitterTest: function(user) {
      return new Promise(function(resolve, reject) {
        return $http.post('/api/twitterTest', {
          user: user
        }).success(function(data) {
          console.log('twitterTest in service data = ', data);
          return resolve(data);
        });
      });
    },
    twitterPostTest: function(user) {
      return new Promise(function(resolve, reject) {
        return $http.post('/api/twitterPostTest', {
          user: user
        }).success(function(data) {
          console.log('twitterPostTest in service data = ', data);
          return resolve(data);
        });
      });
    },
    getHomeTimeline: function(type, twitterIdStr) {
      return new Promise(function(resolve, reject) {
        return $http.get("/api/timeline/:" + type + "/" + twitterIdStr).success(function(data) {
          return resolve(data.data);
        });
      });
    },
    getUserTimeline: function(type, twitterIdStr) {
      return new Promise(function(resolve, reject) {
        return $http.get("/api/timeline/:" + type + "/" + twitterIdStr).success(function(data) {
          return resolve(data.data);
        });
      });
    },

    /*
    List
     */
    getListsList: function() {
      return $q(function(resolve, reject) {
        return $http.get('/api/lists/list').success(function(data) {
          console.table(data.data);
          return resolve(data);
        });
      });
    },
    getListsMembers: function(params) {
      return $q(function(resolve, reject) {
        return $http.get("/api/lists/members/" + params.listIdStr + "/" + params.count).success(function(data) {
          return resolve(data);
        });
      });
    },
    getListsStatuses: function(params) {
      return $q(function(resolve, reject) {
        return $http.get("/api/lists/statuses/" + params.listIdStr + "/" + params.maxId + "/" + params.count).success(function(data) {
          return resolve(data);
        });
      });
    },
    createListsMembers: function(params) {
      return $q(function(resolve, reject) {
        return $http.post("/api/lists/members/create", {
          listIdStr: params.listIdStr,
          twitterIdStr: params.twitterIdStr
        }).success(function(data) {
          return resolve(data);
        });
      });
    },
    destroyListsMembers: function(params) {
      return $q(function(resolve, reject) {
        return $http.post("/api/lists/members/destroy", {
          listIdStr: params.listIdStr,
          twitterIdStr: params.twitterIdStr
        }).success(function(data) {
          return resolve(data);
        });
      });
    },

    /*
    Timleine
     */
    getUserTimeline: function(params) {
      return $q(function(resolve, reject) {
        return $http.get("/api/timeline/" + params.twitterIdStr + "/" + params.maxId + "/" + params.count).success(function(data) {
          return resolve(data);
        });
      });
    },

    /*
    FAV
     */
    createFav: function(params) {
      return $q(function(resolve, reject) {
        return $http.post('/api/createFav', {
          tweetIdStr: params.tweetIdStr
        }).success(function(data) {
          return resolve(data);
        });
      });
    }
  };

  /*
  RT
   */
}]);
