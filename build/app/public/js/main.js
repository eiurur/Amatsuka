angular.module('myApp', ['ngRoute', 'ngAnimate', 'ngSanitize', 'infinite-scroll', 'myApp.controllers', 'myApp.filters', 'myApp.services', 'myApp.factories', 'myApp.directives']).config(["$routeProvider", "$locationProvider", function($routeProvider, $locationProvider) {
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

angular.module("myApp.directives", []).directive('boxLoading', ["$interval", function($interval) {
  return {
    restrict: 'E',
    link: function(scope, element, attrs) {
      var allocations, animate, count, rotate, tag;
      tag = '<div class="box-loader">\n  <b></b>\n  <b></b>\n  <b></b>\n  <b></b>\n  <b></b>\n  <b></b>\n  <b></b>\n  <b></b>\n  <b></b>\n</div>';
      element.append(tag);
      count = 0;
      allocations = [0, 1, 2, 5, 8, 7, 6, 3];
      rotate = function() {
        var bs;
        bs = element.find('b');
        _.map(bs, function(elem) {
          return elem.style.background = attrs.base;
        });
        bs[allocations[count]].style.background = attrs.highlight;
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
}).directive("imgPreload", function() {
  return {
    restrict: "A",
    link: function(scope, element, attrs) {
      return element.on("load", function() {
        return element.addClass("in");
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
}).directive("zoomImage", ["$rootScope", "TweetService", function($rootScope, TweetService) {
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
        var dirction, h, imageLayer, imageLayerImg, w;
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
        imageLayerImg.addClass("image-layer__img-" + dirction + "-wide");
        return imageLayer.on('click', function() {
          imageLayer.html('');
          return imageLayer.removeClass('image-layer__overlay');
        });
      });
    }
  };
}]);

angular.module("myApp.factories", []).factory('Tweets', ["$http", "$q", "TweetService", "ListService", function($http, $q, TweetService, ListService) {
  var Tweets;
  Tweets = (function() {
    function Tweets(items, maxId, type, twitterIdStr) {
      if (maxId == null) {
        maxId = void 0;
      }
      this.busy = false;
      this.isLast　 = false;
      this.method = null;
      this.count = 50;
      this.items = items;
      this.maxId = maxId;
      this.type = type;
      this.twitterIdStr = twitterIdStr || null;
    }

    Tweets.prototype.addTweet = function(tweet) {
      return [this.items][0].push(tweet);
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
      console.time('get');
      return this.method.then((function(_this) {
        return function(data) {
          var itemsImageOnly, itemsNomalized;
          console.timeEnd('get');
          console.log(data);
          console.log('@method maxId', _this.maxId);
          if (_.isEmpty(data.data)) {
            _this.isLast = true;
            _this.busy = false;
            return;
          }
          console.time('decStrNum');
          _this.maxId = TweetService.decStrNum(_.last(data.data).id_str);
          console.timeEnd('decStrNum');
          console.time('filterIncludeImage');
          itemsImageOnly = TweetService.filterIncludeImage(data.data);
          console.timeEnd('filterIncludeImage');
          console.time('nomalizeTweets');
          itemsNomalized = TweetService.nomalizeTweets(itemsImageOnly, ListService.amatsukaList.member);
          console.timeEnd('nomalizeTweets');
          return itemsNomalized;
        };
      })(this)).then((function(_this) {
        return function(itemsNomalized) {
          return (function() {
            console.time('$q.all ');
            $q.all(itemsNomalized.map(function(item) {
              return _this.addTweet(item);
            })).then(function(result) {
              _this.busy = false;
              return console.timeEnd('$q.all ');
            });
          })();
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
    return;
  }
  return $scope.toggleDisplayFormat = ConfigService.toggleDisplayFormat;
}]);

angular.module("myApp.controllers").controller("FavCtrl", ["$scope", "$location", "AuthService", "TweetService", "ListService", "Tweets", function($scope, $location, AuthService, TweetService, ListService, Tweets) {
  var ls;
  if (_.isEmpty(AuthService.user)) {
    return;
  }
  ls = localStorage;
  $scope.isLoaded = false;
  ListService.amatsukaList = {
    data: JSON.parse(ls.getItem('amatsukaList')) || {},
    member: JSON.parse(ls.getItem('amatsukaFollowList')) || []
  };
  if (!ListService.hasListData()) {
    console.log('Go /fav to /');
    $location.path('/');
  }
  $scope.tweets = new Tweets([], void 0, 'fav', AuthService.user._json.id_str);
  $scope.isLoaded = true;
  return $scope.$on('addMember', function(event, args) {
    console.log('addMember on ', args);
    return TweetService.applyFollowStatusChange($scope.tweets.items, args);
  });
}]);

angular.module("myApp.controllers").controller("IndexCtrl", ["$scope", "$rootScope", "AuthService", "TweetService", "ListService", "Tweets", function($scope, $rootScope, AuthService, TweetService, ListService, Tweets) {
  var ls;
  if (_.isEmpty(AuthService.user)) {
    return;
  }
  $scope.listIdStr = '';
  $scope.isLoaded = false;
  ls = localStorage;
  ListService.amatsukaList = {
    data: JSON.parse(ls.getItem('amatsukaList')) || {},
    member: JSON.parse(ls.getItem('amatsukaFollowList')) || []
  };
  ListService.isReturnSameUser().then(function(isSame) {
    if (isSame) {
      console.log('同じ！１');
      $scope.tweets = new Tweets([]);
      ListService.update().then(function(data) {
        return console.log('ok');
      });
      return;
    }
    console.log('違う');
    return ListService.update().then(function(data) {
      console.info('2.1');
      console.log('nnn data = ', data);
      return $scope.tweets = new Tweets([]);
    })["catch"](function(error) {
      console.info('2.2');
      console.log(error);
      return ListService.init().then(function(data) {
        console.info('3');
        console.log('init');
        return $scope.tweets = new Tweets([]);
      });
    });
  })["finally"](function() {
    console.info('10');
    console.log($scope.tweets);
    $scope.listIdStr = ListService.amatsukaList.data.id_str;
    $scope.isLoaded = true;
    return console.log('終わり');
  });
  return $scope.$on('addMember', function(event, args) {
    console.log('addMember on ', args);
    return TweetService.applyFollowStatusChange($scope.tweets.items, args);
  });
}]);

angular.module("myApp.controllers").controller("ListCtrl", ["$scope", "AuthService", "TweetService", "Tweets", function($scope, AuthService, TweetService, Tweets) {
  if (_.isEmpty(AuthService.user)) {
    return;
  }
  console.log('List AuthService.user = ', AuthService.user);
  return TweetService.getListsList().then(function(data) {
    return $scope.lists = data.data;
  }).then(data);
}]);

angular.module("myApp.controllers").controller("MemberCtrl", ["$scope", "AuthService", "TweetService", "ListService", function($scope, AuthService, TweetService, ListService) {
  var ls;
  if (_.isEmpty(AuthService.user)) {
    return;
  }
  $scope.limitNum = 10;
  $scope.listIdStr = null;
  $scope.amatsukaMemberList = null;
  if (ListService.hasListData()) {
    $scope.listIdStr = ListService.amatsukaList.data.id_str;
    $scope.amatsukaMemberList = ListService.nomarlizeMembers(ListService.amatsukaList.member);
    $scope.limitNum = 10000;
    return;
  }
  ls = localStorage;
  $scope.listIdStr = JSON.parse(ls.getItem('amatsukaList')) || {};
  $scope.amatsukaMemberList = JSON.parse(ls.getItem('amatsukaFollowList')) || [];
  return ListService.update().then(function(users) {
    console.log(users);
    $scope.listIdStr = ListService.amatsukaList.data.id_str;
    $scope.amatsukaMemberList = ListService.nomarlizeMembers(users);
    return $scope.limitNum = 100000;
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
    console.log(ListService.amatsukaList);
    $scope.user = ListService.nomarlizeMember(args);
    return $scope.listIdStr = ListService.amatsukaList.data.id_str;
  });
  $scope.$on('tweetData', function(event, args) {
    var maxId, tweetsNomalized, tweetsOnlyImage;
    if (!$scope.isOpened) {
      return;
    }
    maxId = TweetService.decStrNum(_.last(args).id_str);
    tweetsOnlyImage = TweetService.filterIncludeImage(args);
    tweetsNomalized = TweetService.nomalizeTweets(tweetsOnlyImage);
    console.log('UserCrel tweetsNomalized = ', tweetsNomalized);
    return $scope.tweets = new Tweets(tweetsNomalized, maxId, 'user_timeline', $scope.user.id_str);
  });
  $scope.$on('isOpened', function(event, args) {
    $scope.isOpened = true;
    $scope.user = {};
    return $scope.tweets = {};
  });
  $scope.$on('isClosed', function(event, args) {
    return $scope.isOpened = false;
  });
  return $scope.$on('addMember', function(event, args) {
    if (_.isUndefined($scope.tweets)) {
      return;
    }
    console.log('addMember on', args);
    return TweetService.applyFollowStatusChange($scope.tweets.items, args);
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
        var opts;
        console.log(scope.listIdStr);
        console.log(scope.twitterIdStr);
        opts = {
          listIdStr: scope.listIdStr,
          twitterIdStr: scope.twitterIdStr
        };
        if (scope.followStatus === false) {
          element.addClass('label-success');
          element.fadeOut(200);
          return TweetService.createListsMembers(opts).then(function(data) {
            ListService.addMember(scope.twitterIdStr);
            $rootScope.$broadcast('addMember', scope.twitterIdStr);
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
            TweetService.removeMember(scope.twitterIdStr);
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
      return ls.setItem('amatsukaFollowList', JSON.stringify(this.amatsukaList.member));
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
      return this.registerMember2LocalStorage();
    },
    isFollow: function(target, isRT) {
      if (isRT == null) {
        isRT = true;
      }
      if (_.has(target, 'user')) {
        return !!_.findWhere(this.amatsukaList.member, {
          'id_str': TweetService.get(target, 'user.id_str', isRT)
        });
      } else {
        return !!_.findWhere(this.amatsukaList.member, {
          'id_str': target.id_str
        });
      }
    },
    nomarlizeMembers: function(members) {
      return _.each(members, function(member) {
        member.followStatus = true;
        member.description = TweetService.activateLink(member.description);
        return member.profile_image_url = TweetService.iconBigger(member.profile_image_url);
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
      console.log(AuthService.user);
      params = {
        twitterIdStr: AuthService.user._json.id_str
      };
      return TweetService.getListsList(params).then((function(_this) {
        return function(data) {
          _this.amatsukaList.data = _.findWhere(data.data, {
            'name': 'Amatsuka'
          });
          console.log(_this.amatsukaList.data);
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
    isReturnSameUser: function() {
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
        console.log(oldList);
        console.log(newList);
        console.log(oldList.id_str === newList.id_str);
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
          return tweet.followStatus = id_str === twitterIdStr ? true : false;
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
    get: function(tweet, key, isRT) {
      var t, _ref, _ref1, _ref10, _ref11, _ref12, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
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
        case 'media_url_https':
          return (_ref7 = t.entities) != null ? (_ref8 = _ref7.media) != null ? _ref8[0].media_url_https : void 0 : void 0;
        case 'media_url:orig':
          return ((_ref9 = t.entities) != null ? (_ref10 = _ref9.media) != null ? _ref10[0].media_url : void 0 : void 0) + ':orig';
        case 'media_url_https:orig':
          return ((_ref11 = t.entities) != null ? (_ref12 = _ref11.media) != null ? _ref12[0].media_url_https : void 0 : void 0) + ':orig';
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
