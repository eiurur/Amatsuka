angular.module('myApp', ['ngRoute', 'ngAnimate', 'ngSanitize', 'infinite-scroll', 'wu.masonry', 'toaster', 'myApp.controllers', 'myApp.filters', 'myApp.services', 'myApp.factories', 'myApp.directives']).value('THROTTLE_MILLISECONDS', 300).config(["$routeProvider", "$locationProvider", function($routeProvider, $locationProvider) {
  $routeProvider.when('/', {
    templateUrl: 'partials/index',
    controller: 'IndexCtrl'
  }).when('/member', {
    templateUrl: 'partials/member',
    controller: 'MemberCtrl'
  }).when('/list', {
    templateUrl: 'partials/list',
    controller: 'ListCtrl'
  }).when('/fav', {
    templateUrl: 'partials/fav',
    controller: 'FavCtrl'
  }).when('/config', {
    templateUrl: 'partials/config',
    controller: 'ConfigCtrl'
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

angular.module("myApp.directives", []).directive('dotLoader', function() {
  return {
    restrict: 'E',
    template: '<div class="wrapper">\n  <div class="dot"></div>\n  <div class="dot"></div>\n  <div class="dot"></div>\n</div>'
  };
}).directive("imgPreload", function() {
  return {
    restrict: "A",
    link: function(scope, element, attrs) {
      element.on("load", function() {
        element.addClass("in");
      }).on("error", function() {});
    }
  };
}).directive("scrollOnClick", function() {
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
}).directive('resize', ["$timeout", "$rootScope", "$window", function($timeout, $rootScope, $window) {
  return {
    link: function() {
      var timer;
      timer = false;
      return angular.element($window).on('load resize', function(e) {
        if (timer) {
          $timeout.cancel(timer);
        }
        timer = $timeout(function() {
          var cW, html, layoutType;
          html = angular.element(document).find('html');
          cW = html[0].clientWidth;
          console.log('broadCast resize ', cW);
          layoutType = cW < 700 ? 'list' : 'grid';
          return $rootScope.$broadcast('resize::resize', {
            layoutType: layoutType
          });
        }, 200);
      });
    }
  };
}]).directive("zoomImage", ["$rootScope", "TweetService", function($rootScope, TweetService) {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      var html;
      html = '';
      element.on('mouseenter', function() {
        var imageLayer;
        imageLayer = angular.element(document).find('.image-layer');
        html = "<img\n  src=\"" + attrs.imgSrc + ":orig\"\n  class=\"image-layer__img image-layer__img--hidden\" />";
        return imageLayer.html(html);
      });
      return element.on('click', function() {
        var cH, cH_cW_percent, cW, dirction, h, h_w_percent, imageLayer, imageLayerImg, w;
        html = angular.element(document).find('html');
        imageLayer = angular.element(document).find('.image-layer');
        imageLayer.addClass('image-layer__overlay');
        imageLayerImg = angular.element(document).find('.image-layer__img');
        imageLayerImg.removeClass('image-layer__img--hidden');
        if (imageLayerImg[0].naturalHeight == null) {
          return;
        }
        h = imageLayerImg[0].naturalHeight;
        w = imageLayerImg[0].naturalWidth;
        dirction = h > w ? 'h' : 'w';
        console.log(h, w);
        h_w_percent = h / w * 100;
        if ((50 < h_w_percent && h_w_percent < 75)) {
          console.log('横長', h_w_percent);
          dirction = 'w';
        } else if ((100 <= h_w_percent && h_w_percent < 125)) {
          console.log('縦長', h_w_percent);
          dirction = 'h';
        }
        cH = html[0].clientHeight;
        cW = html[0].clientWidth;
        cH_cW_percent = cH / cW * 100;
        console.log('cH_cW_percent = ', cH_cW_percent);
        if (cH_cW_percent < 75) {
          console.log('c 横長', cH_cW_percent);
          dirction = 'h';
        } else if (125 < cH_cW_percent) {
          console.log('c 縦長', cH_cW_percent);
          dirction = 'w';
        }
        imageLayerImg.addClass("image-layer__img-" + dirction + "-wide");
        return imageLayer.on('click', function() {
          imageLayer.html('');
          return imageLayer.removeClass('image-layer__overlay');
        });
      });
    }
  };
}]).directive('downloadFromUrl', ["toaster", "DownloadService", "ConvertService", function(toaster, DownloadService, ConvertService) {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      return element.on('click', function(event) {
        toaster.pop('wait', "Now Downloading ...", '', 1000, 'trustedHtml');
        return DownloadService.exec(attrs.url).success(function(data) {
          var blob, ext, filename;
          blob = ConvertService.base64toBlob(data.base64Data);
          ext = /media\/.*\.(png|jpg|jpeg):orig/.exec(attrs.url)[1];
          filename = "" + attrs.filename + "." + ext;
          saveAs(blob, filename);
          return toaster.pop('success', "Finished Download", '', 1000, 'trustedHtml');
        });
      });
    }
  };
}]);

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module("myApp.factories", []).factory('Tweets', ["$http", "$q", "ToasterService", "TweetService", "ListService", function($http, $q, ToasterService, TweetService, ListService) {
  var Tweets;
  Tweets = (function() {
    function Tweets(items, maxId, type, twitterIdStr) {
      if (maxId == null) {
        maxId = void 0;
      }
      this.checkError = __bind(this.checkError, this);
      this.assignTweet = __bind(this.assignTweet, this);
      this.normalizeTweet = __bind(this.normalizeTweet, this);
      this.busy = false;
      this.isLast　 = false;
      this.method = null;
      this.count = 50;
      this.items = items;
      this.maxId = maxId;
      this.type = type;
      this.twitterIdStr = twitterIdStr || null;
    }

    Tweets.prototype.normalizeTweet = function(data) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          var itemsImageOnly, itemsNomalized;
          if (data.err != null) {
            reject(data.err);
          }
          if (_.isEmpty(data.data)) {
            reject({
              statusCode: 10100
            });
          }
          _this.maxId = TweetService.decStrNum(_.last(data.data).id_str);
          itemsImageOnly = TweetService.filterIncludeImage(data.data);
          itemsNomalized = TweetService.nomalizeTweets(itemsImageOnly, ListService.amatsukaList.member);
          return resolve(itemsNomalized);
        };
      })(this));
    };

    Tweets.prototype.assignTweet = function(tweets) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          if (_.isEmpty(tweets)) {
            reject({
              statusCode: 100110
            });
          }
          (function() {
            $q.all(tweets.map(function(tweet) {
              return [_this.items][0].push(tweet);
            })).then(function(result) {
              return _this.busy = false;
            });
          })();
        };
      })(this));
    };

    Tweets.prototype.checkError = function(statusCode) {
      console.log(statusCode);
      switch (statusCode) {
        case 429:
          ToasterService.warning({
            title: 'ツイート取得API制限',
            text: '15分お待ちください'
          });
          break;
        case 10100:
          this.isLast = true;
          this.busy = false;
          ToasterService.success({
            title: '全ツイート取得完了',
            text: '全て読み込みました'
          });
          break;
        case 10110:
          this.busy = false;
      }
    };

    Tweets.prototype.nextPage = function() {
      console.log(this.busy);
      console.log(this.isLast);
      if (this.busy || this.isLast) {
        return;
      }
      if (this.type === 'user_timeline') {
        this.method = TweetService.getUserTimeline({
          twitterIdStr: this.twitterIdStr,
          maxId: this.maxId,
          count: this.count
        });
      } else if (this.type === 'fav') {
        this.method = TweetService.getFavLists({
          twitterIdStr: this.twitterIdStr,
          maxId: this.maxId,
          count: this.count
        });
      } else {
        this.method = TweetService.getListsStatuses({
          listIdStr: ListService.amatsukaList.data.id_str,
          maxId: this.maxId,
          count: this.count
        });
      }
      this.busy = true;
      return (function(_this) {
        return function() {
          _this.method.then(function(data) {
            return _this.normalizeTweet(data);
          }).then(function(itemsNomalized) {
            return _this.assignTweet(itemsNomalized);
          })["catch"](function(error) {
            return _this.checkError(error.statusCode);
          });
        };
      })(this)();
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
}]).filter('trusted', ["$sce", function($sce) {
  return function(url) {
    return $sce.trustAsResourceUrl(url);
  };
}]);

angular.module("myApp.services", []).service("CommonService", function() {
  return {
    isLoaded: false
  };
}).service('ToasterService', ["toaster", function(toaster) {
  return {
    success: function(notify) {
      console.log(notify.title);
      return toaster.pop('success', notify.title, notify.text);
    },
    warning: function(notify) {
      console.log(notify.title);
      return toaster.pop('warning', notify.title, notify.text);
    }
  };
}]).service('DownloadService', ["$http", function($http) {
  return {
    exec: function(url) {
      return $http.post('/api/download', {
        url: url
      });
    }
  };
}]).service('ConvertService', function() {
  return {
    base64toBlob: function(_base64) {
      var arr, blob, data, i, mime, tmp;
      i = void 0;
      tmp = _base64.split(',');
      data = atob(tmp[1]);
      mime = tmp[0].split(':')[1].split(';')[0];
      arr = new Uint8Array(data.length);
      i = 0;
      while (i < data.length) {
        arr[i] = data.charCodeAt(i);
        i++;
      }
      blob = new Blob([arr], {
        type: mime
      });
      return blob;
    }
  };
});

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

angular.module("myApp.controllers").controller("ConfigCtrl", ["$scope", "AuthService", "TweetService", "ConfigService", "Tweets", function($scope, AuthService, TweetService, ConfigService, Tweets) {
  if (_.isEmpty(AuthService.user)) {

  }
}]);

angular.module("myApp.controllers").controller("FavCtrl", ["$scope", "$location", "AuthService", "TweetService", "ListService", "Tweets", function($scope, $location, AuthService, TweetService, ListService, Tweets) {
  var ls;
  if (_.isEmpty(AuthService.user)) {
    return;
  }
  $scope.isLoaded = false;
  $scope.layoutType = 'grid';
  ls = localStorage;
  ListService.amatsukaList = {
    data: JSON.parse(ls.getItem('amatsukaList')) || {},
    member: JSON.parse(ls.getItem('amatsukaFollowList')) || []
  };
  if (!ListService.hasListData()) {
    console.log('Go /fav to /');
    $location.path('/');
  }
  $scope.tweets = new Tweets([], void 0, 'fav', AuthService.user._json.id_str);
  $scope.listIdStr = ListService.amatsukaList.data.id_str;
  $scope.isLoaded = true;
  $scope.$on('addMember', function(event, args) {
    console.log('fav addMember on ', args);
    TweetService.applyFollowStatusChange($scope.tweets.items, args);
  });
  return $scope.$on('resize::resize', function(event, args) {
    console.log('fav resize::resize on ', args.layoutType);
    $scope.$apply(function() {
      $scope.layoutType = args.layoutType;
    });
  });
}]);

angular.module("myApp.controllers").controller("IndexCtrl", ["$window", "$scope", "$rootScope", "AuthService", "TweetService", "ListService", "Tweets", function($window, $scope, $rootScope, AuthService, TweetService, ListService, Tweets) {
  var ls;
  if (_.isEmpty(AuthService.user)) {
    return;
  }
  $scope.listIdStr = '';
  $scope.isLoaded = false;
  $scope.layoutType = 'grid';
  ls = localStorage;
  ListService.amatsukaList = {
    data: JSON.parse(ls.getItem('amatsukaList')) || {},
    member: JSON.parse(ls.getItem('amatsukaFollowList')) || []
  };
  ListService.isSameUser().then(function(isSame) {
    if (isSame) {
      $scope.tweets = new Tweets([]);
      (function() {
        ListService.update().then(function(data) {
          return console.log('ok');
        });
      })();
      return;
    }
    ListService.update().then(function(data) {
      $scope.tweets = new Tweets([]);
    })["catch"](function(error) {
      ListService.init().then(function(data) {
        $scope.tweets = new Tweets([]);
      });
    });
  })["finally"](function() {
    console.info('10');
    $scope.listIdStr = ListService.amatsukaList.data.id_str;
    $scope.isLoaded = true;
    console.log('終わり');
  });
  $scope.$on('addMember', function(event, args) {
    console.log('index addMember on ', args);
    TweetService.applyFollowStatusChange($scope.tweets.items, args);
  });
  return $scope.$on('resize::resize', function(event, args) {
    console.log('index resize::resize on ', args.layoutType);
    $scope.$apply(function() {
      $scope.layoutType = args.layoutType;
    });
  });
}]);

angular.module("myApp.controllers").controller("ListCtrl", ["$scope", "AuthService", "TweetService", "Tweets", function($scope, AuthService, TweetService, Tweets) {
  if (_.isEmpty(AuthService.user)) {

  }
}]);

angular.module("myApp.controllers").controller("MemberCtrl", ["$scope", "AuthService", "TweetService", "ListService", function($scope, AuthService, TweetService, ListService) {
  var ls;
  if (_.isEmpty(AuthService.user)) {
    return;
  }
  $scope.limitNum = 20;
  $scope.listIdStr = null;
  $scope.amatsukaMemberList = null;
  if (ListService.hasListData()) {
    $scope.listIdStr = ListService.amatsukaList.data.id_str;
    $scope.amatsukaMemberList = ListService.nomarlizeMembers(ListService.amatsukaList.member);
    return;
  }
  ls = localStorage;
  $scope.listIdStr = JSON.parse(ls.getItem('amatsukaList')) || {};
  $scope.amatsukaMemberList = JSON.parse(ls.getItem('amatsukaFollowList')) || [];
  return ListService.update().then(function(users) {
    console.log(users);
    $scope.listIdStr = ListService.amatsukaList.data.id_str;
    return $scope.amatsukaMemberList = ListService.nomarlizeMembers(users);
  });
}]);

angular.module("myApp.controllers").controller("UserCtrl", ["$scope", "$rootScope", "AuthService", "TweetService", "ListService", "Tweets", function($scope, $rootScope, AuthService, TweetService, ListService, Tweets) {
  if (_.isEmpty(AuthService.user)) {
    return;
  }
  $scope.isOpened = false;
  $scope.$on('userData', function(event, args) {
    if (!$scope.isOpened) {
      return;
    }
    $scope.user = ListService.nomarlizeMember(args);
    $scope.listIdStr = ListService.amatsukaList.data.id_str;
  });
  $scope.$on('tweetData', function(event, args) {
    var maxId, tweetsNomalized, tweetsOnlyImage;
    if (!$scope.isOpened) {
      return;
    }
    maxId = TweetService.decStrNum(_.last(args).id_str);
    tweetsOnlyImage = TweetService.filterIncludeImage(args);
    tweetsNomalized = TweetService.nomalizeTweets(tweetsOnlyImage);
    $scope.tweets = new Tweets(tweetsNomalized, maxId, 'user_timeline', $scope.user.id_str);
  });
  $scope.$on('isOpened', function(event, args) {
    $scope.isOpened = true;
    $scope.user = {};
    $scope.tweets = {};
  });
  $scope.$on('isClosed', function(event, args) {
    $scope.isOpened = false;
    $scope.user = null;
    $scope.tweets = null;
  });
  return $scope.$on('addMember', function(event, args) {
    if (_.isUndefined($scope.tweets)) {
      return;
    }
    console.log('user addMember on', args);
    TweetService.applyFollowStatusChange($scope.tweets.items, args);
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
    scope: {
      favNum: '=',
      favorited: '=',
      tweetIdStr: '@'
    },
    link: function(scope, element, attrs) {
      if (scope.favorited) {
        element.addClass('favorited');
      }
      return element.on('click', function(event) {
        console.log('favorited = ', scope.favorited);
        if (scope.favorited) {
          element.removeClass('favorited');
          return TweetService.destroyFav({
            tweetIdStr: scope.tweetIdStr
          }).then(function(data) {
            scope.favNum -= 1;
            return scope.favorited = !scope.favorited;
          });
        } else {
          element.addClass('favorited');
          return TweetService.createFav({
            tweetIdStr: scope.tweetIdStr
          }).then(function(data) {
            scope.favNum += 1;
            return scope.favorited = !scope.favorited;
          });
        }
      });
    }
  };
}]).directive('retweetable', ["TweetService", function(TweetService) {
  return {
    restrict: 'A',
    scope: {
      retweetNum: '=',
      retweeted: '=',
      tweetIdStr: '@'
    },
    link: function(scope, element, attrs) {
      if (scope.retweeted) {
        element.addClass('retweeted');
      }
      return element.on('click', function(event) {
        if (scope.retweeted) {
          element.removeClass('retweeted');
          return TweetService.destroyStatus({
            tweetIdStr: scope.tweetIdStr
          }).then(function(data) {
            scope.retweetNum -= 1;
            return scope.retweeted = !scope.retweeted;
          });
        } else if (window.confirm('リツイートしてもよろしいですか？')) {
          element.addClass('retweeted');
          return TweetService.retweetStatus({
            tweetIdStr: scope.tweetIdStr
          }).then(function(data) {
            scope.retweetNum += 1;
            return scope.retweeted = !scope.retweeted;
          });
        }
      });
    }
  };
}]).directive('followable', ["$rootScope", "ListService", "TweetService", function($rootScope, ListService, TweetService) {
  return {
    restrict: 'E',
    replace: true,
    scope: {
      listIdStr: '@',
      tweet: '@',
      followStatus: '='
    },
    template: '<span class="label label-default timeline__post--header--label">{{content}}</span>',
    link: function(scope, element, attrs) {
      var isRT, tweetParsed, twitterIdStr;
      tweetParsed = JSON.parse(scope.tweet);
      isRT = TweetService.isRT(tweetParsed);
      twitterIdStr = TweetService.get(tweetParsed, 'user.id_str', isRT);
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
        var opts;
        console.log(scope.listIdStr);
        console.log(twitterIdStr);
        opts = {
          listIdStr: scope.listIdStr,
          twitterIdStr: twitterIdStr
        };
        if (scope.followStatus === false) {
          element.addClass('label-success');
          element.fadeOut(200);
          return TweetService.createListsMembers(opts).then(function(data) {
            ListService.addMember(twitterIdStr);
            $rootScope.$broadcast('addMember', twitterIdStr);
            return console.log('E followable createListsMembers data', data);
          });
        }
      });
    }
  };
}]).directive('followable', ["$rootScope", "ListService", "TweetService", function($rootScope, ListService, TweetService) {
  return {
    restrict: 'A',
    scope: {
      listIdStr: '@',
      twitterIdStr: '@',
      followStatus: '='
    },
    link: function(scope, element, attrs) {
      element[0].innerText = scope.followStatus ? 'フォロー解除' : 'フォロー';
      return element.on('click', function() {
        var opts;
        console.log(scope.listIdStr);
        console.log(scope.twitterIdStr);
        opts = {
          listIdStr: scope.listIdStr,
          twitterIdStr: scope.twitterIdStr
        };
        scope.isProcessing = true;
        if (scope.followStatus === true) {
          element[0].innerText = 'フォロー';
          TweetService.destroyListsMembers(opts).then(function(data) {
            ListService.removeMember(scope.twitterIdStr);
            return scope.isProcessing = false;
          });
        }
        if (scope.followStatus === false) {
          element[0].innerText = 'フォロー解除';
          TweetService.createListsMembers(opts).then(function(data) {
            ListService.addMember(scope.twitterIdStr);
            $rootScope.$broadcast('addMember', scope.twitterIdStr);
            return scope.isProcessing = false;
          });
        }
        return scope.followStatus = !scope.followStatus;
      });
    }
  };
}]).directive('showTweet', ["$rootScope", "TweetService", function($rootScope, TweetService) {
  return {
    restrict: 'A',
    scope: {
      twitterIdStr: '@'
    },
    link: function(scope, element, attrs) {
      var showTweet;
      showTweet = function() {
        return TweetService.showUsers({
          twitterIdStr: scope.twitterIdStr
        }).then(function(data) {
          console.log(data);
          $rootScope.$broadcast('userData', data.data);
          return TweetService.getUserTimeline({
            twitterIdStr: scope.twitterIdStr
          });
        }).then(function(data) {
          console.log(data.data);
          return $rootScope.$broadcast('tweetData', data.data);
        });
      };
      return element.on('click', function() {
        var body, domUserSidebar, isOpenedSidebar, layer;
        $rootScope.$broadcast('isOpened', true);
        domUserSidebar = angular.element(document).find('.user-sidebar');
        isOpenedSidebar = domUserSidebar[0].className.indexOf('.user-sidebar-in') !== -1;
        if (isOpenedSidebar) {
          console.log('-in もってる');
          showTweet();
          return;
        }
        domUserSidebar.addClass('user-sidebar-in');
        body = angular.element(document).find('body');
        body.addClass('scrollbar-y-hidden');
        layer = angular.element(document).find('.layer');
        layer.addClass('fullscreen-overlay');
        showTweet();
        return layer.on('click', function() {
          body.removeClass('scrollbar-y-hidden');
          layer.removeClass('fullscreen-overlay');
          domUserSidebar.removeClass('user-sidebar-in');
          return $rootScope.$broadcast('isClosed', true);
        });
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
        var params;
        scope.isProcessing = true;
        params = {
          listIdStr: scope.listIdStr,
          count: 50
        };
        return TweetService.getListsStatuses(params).then(function(data) {
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
    isAuthenticated: function() {
      return $http.get("/isAuthenticated");
    },
    findUserById: function(twitterIdStr) {
      return $http.post("/api/findUserById", twitterIdStr);
    },
    status: {
      isAuthenticated: false
    },
    user: {}
  };
}]);

angular.module("myApp.services").service("ConfigService", ["$http", function($http) {
  return {
    getDisplayFormat: (function(_this) {
      return function() {
        var ls;
        ls = localStorage;
        return _this.displayFormat = JSON.parse(ls.getItem('displayFormat')) || 'list';
      };
    })(this),
    setDisplayFormat: (function(_this) {
      return function() {
        var ls;
        ls = localStorage;
        return ls.setItem('displayFormat', _this.displayFormat);
      };
    })(this),
    toggleDisplayFormat: (function(_this) {
      return function() {
        return _this.displayFormat = _this.displayFormat === 'list' ? 'grid' : 'list';
      };
    })(this),
    toggleIncludeRetweet: (function(_this) {
      return function() {
        return _this.isIncludeRetweet = !_this.isIncludeRetweet;
      };
    })(this),
    displayFormat: 'list',
    isIncludeRetweet: true
  };
}]);

angular.module("myApp.services").service("ListService", ["$http", "$q", "AuthService", "TweetService", function($http, $q, AuthService, TweetService) {
  return {
    amatsukaList: {
      data: [],
      member: {}
    },
    registerMember2LocalStorage: function() {
      var ls;
      ls = localStorage;
      ls.setItem('amatsukaFollowList', JSON.stringify(this.amatsukaList.member));
    },
    addMember: function(twitterIdStr) {
      return TweetService.showUsers({
        twitterIdStr: twitterIdStr
      }).then((function(_this) {
        return function(data) {
          _this.amatsukaList.member.push(data.data);
          return _this.registerMember2LocalStorage();
        };
      })(this));
    },
    removeMember: function(twitterIdStr) {
      this.amatsukaList.member = _.reject(this.amatsukaList.member, {
        'id_str': twitterIdStr
      });
      this.registerMember2LocalStorage();
    },
    isFollow: function(target, isRT) {
      var targetIdStr;
      if (isRT == null) {
        isRT = true;
      }
      targetIdStr = target.id_str;
      if (_.has(target, 'user')) {
        targetIdStr = TweetService.get(target, 'user.id_str', isRT);
      }
      return !!_.findWhere(this.amatsukaList.member, {
        'id_str': targetIdStr
      });
    },
    nomarlizeMembers: function(members) {
      return _.each(members, function(member) {
        member.followStatus = true;
        member.description = TweetService.activateLink(member.description);
        member.profile_image_url = TweetService.iconBigger(member.profile_image_url);
      });
    },
    nomarlizeMember: function(member) {
      member.followStatus = this.isFollow(member);
      member.description = TweetService.activateLink(member.description);
      member.profile_image_url = TweetService.iconBigger(member.profile_image_url);
      return member;
    },
    update: function() {
      var ls, params;
      ls = localStorage;
      params = {
        twitterIdStr: AuthService.user._json.id_str
      };
      return TweetService.getListsList(params).then((function(_this) {
        return function(data) {
          _this.amatsukaList.data = _.findWhere(data.data, {
            'name': 'Amatsuka'
          });
          ls.setItem('amatsukaList', JSON.stringify(_this.amatsukaList.data));
          return TweetService.getListsMembers({
            listIdStr: _this.amatsukaList.data.id_str
          });
        };
      })(this)).then((function(_this) {
        return function(data) {
          _this.amatsukaList.member = data.data.users;
          ls.setItem('amatsukaFollowList', JSON.stringify(_this.amatsukaList.member));
          return data.data.users;
        };
      })(this));
    },
    init: function() {
      var ls, params;
      ls = localStorage;
      params = {
        name: 'Amatsuka',
        mode: 'private'
      };
      return TweetService.createLists(params).then((function(_this) {
        return function(data) {
          _this.amatsukaList.data = data.data;
          ls.setItem('amatsukaList', JSON.stringify(data.data));
          params = {
            listIdStr: data.data.id_str,
            twitterIdStr: void 0
          };
          return TweetService.createAllListsMembers(params);
        };
      })(this)).then(function(data) {
        return TweetService.getListsMembers({
          listIdStr: data.data.id_str
        });
      }).then((function(_this) {
        return function(data) {
          _this.amatsukaList.member = data.data.users;
          ls.setItem('amatsukaFollowList', JSON.stringify(data.data.users));
          return data.data.users;
        };
      })(this));
    },
    isSameUser: function() {
      var ls, params;
      ls = localStorage;
      params = {
        twitterIdStr: AuthService.user._json.id_str
      };
      return TweetService.getListsList(params).then(function(data) {
        var newList, oldList;
        oldList = JSON.parse(ls.getItem('amatsukaList')) || {};
        newList = _.findWhere(data.data, {
          'name': 'Amatsuka'
        }) || {
          id_str: null
        };
        return oldList.id_str === newList.id_str;
      });
    },
    hasListData: function() {
      return !(_.isEmpty(this.amatsukaList.data) && _.isEmpty(this.amatsukaList.member));
    }
  };
}]);

angular.module("myApp.services").service("TweetService", ["$http", "$q", "$injector", function($http, $q, $injector) {
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
    hasOrigParameter: function(tweet) {
      return console.log(tweet);
    },
    applyFollowStatusChange: function(tweets, twitterIdStr) {
      console.log('applyFollowStatusChange tweets = ', tweets);
      return _.map(tweets, (function(_this) {
        return function(tweet) {
          var id_str, isRT;
          isRT = _.has(tweet, 'retweeted_status');
          id_str = _this.get(tweet, 'user.id_str', isRT);
          if (id_str === twitterIdStr) {
            return tweet.followStatus = true;
          }
        };
      })(this));
    },
    nomalizeTweets: function(tweets) {
      var ListService;
      ListService = $injector.get('ListService');
      return _.each(tweets, (function(_this) {
        return function(tweet) {
          var isRT;
          isRT = _.has(tweet, 'retweeted_status');
          tweet.isRT = isRT;
          tweet.followStatus = ListService.isFollow(tweet, isRT);
          tweet.text = _this.activateLink(_this.get(tweet, 'text', isRT));
          tweet.time = _this.fromNow(_this.get(tweet, 'tweet.created_at', false));
          tweet.retweetNum = _this.get(tweet, 'tweet.retweet_count', isRT);
          tweet.favNum = _this.get(tweet, 'tweet.favorite_count', isRT);
          tweet.tweetIdStr = _this.get(tweet, 'tweet.id_str', isRT);
          tweet.sourceUrl = _this.get(tweet, 'display_url', isRT);
          tweet.picUrlList = _this.get(tweet, 'media_url', isRT);
          tweet.picOrigUrlList = _this.get(tweet, 'media_url:orig', isRT);
          tweet.video_url = _this.get(tweet, 'video_url', isRT);
          tweet.fileName = _this.get(tweet, 'screen_name', isRT) + '_' + _this.get(tweet, 'tweet.id_str', isRT);
          tweet.user.profile_image_url = _this.iconBigger(tweet.user.profile_image_url);
        };
      })(this));
    },
    isRT: function(tweet) {
      return _.has(tweet, 'retweeted_status');
    },
    get: function(tweet, key, isRT) {
      var t, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
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
          return _.map(t.extended_entities.media, function(media) {
            return media.media_url;
          });
        case 'media_url_https':
          return _.map(t.extended_entities.media, function(media) {
            return media.media_url_https;
          });
        case 'media_url:orig':
          return _.map(t.extended_entities.media, function(media) {
            return media.media_url + ':orig';
          });
        case 'media_url_https:orig':
          return _.map(t.extended_entities.media, function(media) {
            return media.media_url_https + ':orig';
          });
        case 'video_url':
          return (_ref5 = t.extended_entities) != null ? (_ref6 = _ref5.media[0]) != null ? (_ref7 = _ref6.video_info) != null ? _ref7.variants[0].url : void 0 : void 0 : void 0;
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
      return _.reject(tweets, function(tweet) {
        return !_.has(tweet, 'extended_entities') || _.isEmpty(tweet.extended_entities.media);
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

    /*
    List
     */
    getListsList: function(params) {
      return $q(function(resolve, reject) {
        return $http.get("/api/lists/list/" + params.twitterIdStr).success(function(data) {
          console.table(data.data);
          return resolve(data);
        });
      });
    },
    createLists: function(params) {
      return $q(function(resolve, reject) {
        return $http.post('/api/lists/create', params).success(function(data) {
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
        return $http.post("/api/lists/members/create", params).success(function(data) {
          return resolve(data);
        });
      });
    },
    createAllListsMembers: function(params) {
      return $q(function(resolve, reject) {
        return $http.post("/api/lists/members/create_all", params).success(function(data) {
          return resolve(data);
        });
      });
    },
    destroyListsMembers: function(params) {
      return $q(function(resolve, reject) {
        return $http.post("/api/lists/members/destroy", params).success(function(data) {
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
    User
     */
    showUsers: function(params) {
      return $q(function(resolve, reject) {
        return $http.get("/api/users/show/" + params.twitterIdStr).success(function(data) {
          return resolve(data);
        });
      });
    },

    /*
    FAV
     */
    getFavLists: function(params) {
      return $q(function(resolve, reject) {
        return $http.get("/api/favorites/lists/" + params.twitterIdStr + "/" + params.maxId + "/" + params.count).success(function(data) {
          return resolve(data);
        });
      });
    },
    createFav: function(params) {
      return $q(function(resolve, reject) {
        return $http.post('/api/favorites/create', params).success(function(data) {
          return resolve(data);
        });
      });
    },
    destroyFav: function(params) {
      return $q(function(resolve, reject) {
        return $http.post('/api/favorites/destroy', params).success(function(data) {
          return resolve(data);
        });
      });
    },

    /*
    RT
     */
    retweetStatus: function(params) {
      return $q(function(resolve, reject) {
        return $http.post('/api/statuses/retweet', params).success(function(data) {
          return resolve(data);
        });
      });
    },
    destroyStatus: function(params) {
      return $q(function(resolve, reject) {
        return $http.post('/api/statuses/destroy', params).success(function(data) {
          return resolve(data);
        });
      });
    }
  };
}]);
