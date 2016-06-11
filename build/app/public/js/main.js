angular.module('myApp', ['ngRoute', 'ngAnimate', 'ngSanitize', 'ngTouch', 'infinite-scroll', 'wu.masonry', 'toaster', 'ngTagsInput', 'myApp.controllers', 'myApp.filters', 'myApp.services', 'myApp.factories', 'myApp.directives']).value('THROTTLE_MILLISECONDS', 300).config(["$routeProvider", "$locationProvider", function($routeProvider, $locationProvider) {
  $routeProvider.when('/', {
    templateUrl: 'partials/index',
    controller: 'IndexCtrl'
  }).when('/member', {
    templateUrl: 'partials/member',
    controller: 'MemberCtrl'
  }).when('/list', {
    templateUrl: 'partials/list',
    controller: 'ListCtrl'
  }).when('/find', {
    templateUrl: 'partials/find',
    controller: 'FindCtrl'
  }).when('/extract/:id?', {
    templateUrl: 'partials/extract',
    controller: 'ExtractCtrl'
  }).when('/mao', {
    templateUrl: 'partials/mao'
  }).when('/like', {
    templateUrl: 'partials/like',
    controller: 'LikeCtrl'
  }).when('/config', {
    templateUrl: 'partials/config',
    controller: 'ConfigCtrl'
  }).when('/help', {
    templateUrl: 'partials/help',
    controller: 'HelpCtrl'
  }).when("/logout", {
    redirectTo: "/"
  }).when("http://127.0.0.1:4040/auth/twitter/callback", {
    redirectTo: "/"
  }).otherwise({
    redirectTo: '/'
  });
  return $locationProvider.html5Mode(true);
}]);

angular.module("myApp.controllers", []);

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
}).directive('downloadFromUrl', ["$q", "toaster", "DownloadService", function($q, toaster, DownloadService) {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      return element.on('click', function(event) {
        var promises, urlList;
        urlList = attrs.url.indexOf('[') === -1 ? [attrs.url] : JSON.parse(attrs.url);
        promises = [];
        toaster.pop('wait', "Now Downloading ...", '', 0, 'trustedHtml');
        urlList.forEach(function(url, idx) {
          return promises.push(DownloadService.exec(url, attrs.filename, idx));
        });
        return $q.all(promises).then(function(datas) {
          toaster.clear();
          return toaster.pop('success', "Finished Download", '', 2000, 'trustedHtml');
        });
      });
    }
  };
}]).directive('icNavAutoclose', function() {
  console.log('icNavAutoclose');
  return function(scope, elm, attrs) {
    var collapsible, visible;
    collapsible = $(elm).find('.navbar-collapse');
    visible = false;
    collapsible.on('show.bs.collapse', function() {
      visible = true;
    });
    collapsible.on('hide.bs.collapse', function() {
      visible = false;
    });
    $(elm).find('a').each(function(index, element) {
      $(element).click(function(e) {
        if (e.target.className.indexOf('dropdown-toggle') !== -1) {
          return;
        }
        if (visible && 'auto' === collapsible.css('overflow-y')) {
          collapsible.collapse('hide');
        }
      });
    });
  };
}).directive('clearLocalStorage', ["toaster", function(toaster) {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      return element.on('click', function(event) {
        toaster.pop('wait', "Now Clearing ...", '', 0, 'trustedHtml');
        window.localStorage.clear();
        toaster.clear();
        return toaster.pop('success', "Finished clearing the list data", '', 2000, 'trustedHtml');
      });
    }
  };
}]);

angular.module("myApp.factories", []);

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

angular.module("myApp.services", []);

angular.module("myApp.controllers").controller("AdminUserCtrl", ["$scope", "$location", "AuthService", function($scope, $location, AuthService) {
  $scope.isLoaded = false;
  $scope.isAuthenticated = AuthService.status.isAuthenticated;
  if (AuthService.status.isAuthenticated) {
    $scope.isLoaded = true;
    return;
  }
  return AuthService.isAuthenticated().success(function(data) {
    if (_.isNull(data.data)) {
      $scope.isLoaded = true;
      $location.path('/');
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

angular.module("myApp.controllers").controller("AmatsukaListCtrl", ["AuthService", "ListService", function(AuthService, ListService) {
  var amatsukaFollowList, amatsukaList;
  if (_.isEmpty(AuthService.user)) {
    return;
  }
  amatsukaList = localStorage.getItem('amatsukaList');
  amatsukaList = amatsukaList === 'undefined' ? {} : JSON.parse(amatsukaList);
  amatsukaFollowList = localStorage.getItem('amatsukaFollowList');
  amatsukaFollowList = amatsukaFollowList === 'undefined' ? [] : JSON.parse(amatsukaFollowList);
  if (_.isEmpty(amatsukaList)) {
    window.localStorage.clear();
  }
  return ListService.amatsukaList = {
    data: amatsukaList,
    member: amatsukaFollowList
  };
}]);

angular.module("myApp.controllers").controller("ConfigCtrl", ["$scope", "$location", "AuthService", "ConfigService", function($scope, $location, AuthService, ConfigService) {
  if (_.isEmpty(AuthService.user)) {
    $location.path('/');
  }
  ConfigService.getFromDB().then(function(config) {
    return ConfigService.set(config);
  })["catch"](function(e) {
    return ConfigService.init();
  })["finally"](function() {
    return $scope.config = ConfigService.config;
  });
  return $scope.$watch('config', function(newData, oldData) {
    if (JSON.stringify(newData) === JSON.stringify(oldData)) {
      return;
    }
    if (!_.isNumber(newData.likeLowerLimit)) {
      return;
    }
    ConfigService.update();
    ConfigService.save2DB().then(function(data) {
      return console.log(data);
    })["catch"](function(error) {
      return console.log(error);
    });
  }, true);
}]);

angular.module("myApp.controllers").controller("ExtractCtrl", ["$scope", "$routeParams", "$location", "Tweets", "AuthService", "TweetService", "ListService", "ConfigService", function($scope, $routeParams, $location, Tweets, AuthService, TweetService, ListService, ConfigService) {
  var filterPic, params;
  if (_.isEmpty(AuthService.user)) {
    $location.path('/');
  }
  if (!ListService.hasListData()) {
    $location.path('/');
  }
  $scope.listIdStr = ListService.amatsukaList.data.id_str;
  $scope.layoutType = 'grid';
  $scope.filter = {
    screenName: '',
    keyword: '',
    isIncludeRetweet: false
  };
  $scope.extract = {};
  $scope.extract.tweets = [];
  ConfigService.get().then(function(config) {
    return $scope.layoutType = config.isTileLayout ? 'tile' : 'grid';
  });
  filterPic = function(params) {
    if (params == null) {
      params = {
        screenName: $scope.filter.screenName
      };
    }
    $scope.isLoading = true;
    return TweetService.showUsers(params).then(function(data) {
      return $scope.extract.user = ListService.normalizeMember(data.data);
    }).then(function(user) {
      return TweetService.getAllPict({
        twitterIdStr: user.id_str,
        isIncludeRetweet: $scope.filter.isIncludeRetweet
      });
    }).then(function(tweetListContainedImage) {
      console.log(tweetListContainedImage);
      return _.chain(tweetListContainedImage).filter(function(tweet) {
        return ~tweet.text.indexOf($scope.filter.keyword);
      }).value();
    }).then(function(data) {
      var tweets;
      console.log(data);
      tweets = TweetService.normalizeTweets(data, ListService.amatsukaList.member);
      $scope.extract.tweets = tweets.sort(function(a, b) {
        return b.totalNum - a.totalNum;
      });
      console.log($scope.extract.tweets);
      return $scope.isLoading = false;
    });
  };
  if ($routeParams.id === void 0) {
    console.log('undefined');
  } else {
    console.log($scope.filter.keyword);
    if ($routeParams.id.indexOf('@' === -1)) {
      console.log('@ScreenName');
      params = {
        screenName: $routeParams.id
      };
    } else {
      console.log('id_str');
      params = {
        twitterIdStr: $routeParams.id
      };
    }
    filterPic(params);
  }
  $scope.execFilteringPictWithKeyword = function() {
    console.log($scope.filter);
    return filterPic();
  };
  $scope.$on('addMember', function(event, args) {
    console.log('index addMember on ', args);
    TweetService.applyFollowStatusChange($scope.extract.tweets, args);
  });
  return $scope.$on('resize::resize', function(event, args) {
    console.log('index resize::resize on ', args.layoutType);
    $scope.$apply(function() {
      $scope.layoutType = args.layoutType;
    });
  });
}]);

angular.module("myApp.controllers").controller("FindCtrl", ["$scope", "$location", "AuthService", "ListService", "Pict", function($scope, $location, AuthService, ListService, Pict) {
  if (_.isEmpty(AuthService.user)) {
    $location.path('/');
  }
  if (!ListService.hasListData()) {
    $location.path('/');
  }
  return $scope.pictList = new Pict();
}]);

angular.module("myApp.controllers").controller("HelpCtrl", ["$scope", "$location", "AuthService", function($scope, $location, AuthService) {
  if (_.isEmpty(AuthService.user)) {
    return $location.path('/');
  }
}]);

angular.module("myApp.controllers").controller("IndexCtrl", ["$scope", "$location", "AuthService", "TweetService", "ListService", "ConfigService", "Tweets", function($scope, $location, AuthService, TweetService, ListService, ConfigService, Tweets) {
  var upsertAmatsukaList;
  if (_.isEmpty(AuthService.user)) {
    return;
  }
  if (_.isEmpty(ListService.amatsukaList.data)) {
    window.localStorage.clear();
  }
  $scope.listIdStr = '';
  $scope.isLoaded = false;
  $scope.layoutType = 'grid';
  ConfigService.get().then(function(config) {
    return $scope.layoutType = config.isTileLayout ? 'tile' : 'grid';
  });
  $scope.message = 'リストデータの確認中';
  upsertAmatsukaList = function() {
    $scope.message = 'リストデータの更新中';
    return ListService.update().then(function(data) {
      console.log('==> update() then data = ', data);
      $scope.tweets = new Tweets([]);
    })["catch"](function(error) {
      console.log('==> update() catch error = ', error);
      $scope.message = 'リストを作成中';
      return ListService.init().then(function(data) {
        console.log('===> init() then data ', data);
        ConfigService.init();
        return ConfigService.save2DB();
      }).then(function(data) {
        console.log('===> ConfigService then data = ', data);
        return $scope.tweets = new Tweets([]);
      });
    })["finally"](function() {
      console.log('==> update() finally');
      return $scope.message = '';
    });
  };
  ListService.isSameAmatsukaList().then(function(_isSameAmatsukaList) {
    console.log('=> _isSameAmatsukaList = ', _isSameAmatsukaList);
    if (_isSameAmatsukaList) {
      $scope.tweets = new Tweets([]);
      (function() {
        ListService.update().then(function(data) {
          return console.log('ok');
        });
      })();
      return;
    }
    console.log('=> false _isSameAmatsukaList');
    return upsertAmatsukaList();
  })["catch"](function(error) {
    return console.log('=> catch isSameAmatsukaList error = ', error);
  })["finally"](function() {
    console.log('=> isSameAmatsukaList() finally');
    ConfigService.getFromDB().then(function(data) {
      return $scope.config = data;
    });
    $scope.listIdStr = ListService.amatsukaList.data.id_str;
    $scope.isLoaded = true;
    $scope.message = '';
    console.log('=> 終わり');
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

angular.module("myApp.controllers").controller("LikeCtrl", ["$scope", "$location", "AuthService", "ConfigService", "TweetService", "ListService", "Tweets", function($scope, $location, AuthService, ConfigService, TweetService, ListService, Tweets) {
  if (_.isEmpty(AuthService.user)) {
    $location.path('/');
  }
  if (!ListService.hasListData()) {
    $location.path('/');
  }
  $scope.isLoaded = false;
  ConfigService.get().then(function(config) {
    return $scope.layoutType = config.isTileLayout ? 'tile' : 'grid';
  });
  $scope.tweets = new Tweets([], void 0, 'like', AuthService.user._json.id_str);
  $scope.listIdStr = ListService.amatsukaList.data.id_str;
  $scope.isLoaded = true;
  $scope.$on('addMember', function(event, args) {
    console.log('like addMember on ', args);
    TweetService.applyFollowStatusChange($scope.tweets.items, args);
  });
  return $scope.$on('resize::resize', function(event, args) {
    console.log('like resize::resize on ', args.layoutType);
    $scope.$apply(function() {
      $scope.layoutType = args.layoutType;
    });
  });
}]);

angular.module("myApp.controllers").controller("ListCtrl", ["$scope", "$location", "AuthService", "TweetService", "ListService", "List", "Member", "AmatsukaList", function($scope, $location, AuthService, TweetService, ListService, List, Member, AmatsukaList) {
  if (_.isEmpty(AuthService.user)) {
    $location.path('/');
  }
  if (!ListService.hasListData()) {
    $location.path('/');
  }
  $scope.amatsukaList = new AmatsukaList('Amatsuka');
  TweetService.getListsList(AuthService.user._json.id_str).then(function(data) {
    var l, myFriendParams;
    l = _.reject(data.data, function(list) {
      return list.full_name === ("@" + AuthService.user.username + "/amatsuka");
    });
    $scope.ownList = l || [];
    myFriendParams = {
      name: "friends",
      full_name: "friends",
      id_str: AuthService.user.id_str,
      uri: '/following'
    };
    return $scope.ownList.push(myFriendParams);
  })["catch"](function(error) {
    return console.log('listController = ', error);
  });
  $scope.$watch('sourceListData', function(list) {
    if ((list != null ? list.name : void 0) == null) {
      return;
    }
    console.log(list);
    return (function() {
      $scope.sourceList = {};
      $scope.sourceList = list.name === 'friends' ? new Member(list.name, AuthService.user._json.id_str) : new List(list.name, list.id_str);
      $scope.sourceList.loadMember();
    })();
  });
  $scope.$on('list:addMember', function(event, args) {
    console.log('list:copyMember on', args);
    $scope.amatsukaList.updateAmatsukaList();
  });
  $scope.$on('list:copyMember', function(event, args) {
    console.log('list:copyMember on', args);
    $scope.amatsukaList.updateAmatsukaList();
    $scope.sourceList.members = ListService.changeFollowStatusAllMembers($scope.sourceList.members, true);
    $('.btn-follow').each(function() {
      return this.innerText = 'フォロー解除';
    });
  });
  return $scope.$on('list:removeMember', function(event, args) {
    console.log('list:removeMember on', args);
    $scope.amatsukaList.updateAmatsukaList();
  });
}]);

angular.module("myApp.controllers").controller("MemberCtrl", ["$scope", "$location", "AuthService", "ListService", "AmatsukaList", function($scope, $location, AuthService, ListService, AmatsukaList) {
  if (_.isEmpty(AuthService.user)) {
    $location.path('/');
  }
  if (!ListService.hasListData()) {
    $location.path('/');
  }
  $scope.list = new AmatsukaList('Amatsuka');
  return $scope.$watch('searchWord.screen_name', function(newData, oldData) {
    var idx, member, screenNameTolowerCased, _i, _len, _ref;
    if (newData === oldData) {
      return;
    }
    if (newData === '') {
      $scope.list.members = [];
      $scope.list.memberIdx = 0;
      _ref = $scope.list.amatsukaMemberList;
      for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
        member = _ref[idx];
        if (idx > 20) {
          return;
        }
        $scope.list.members.push(member);
        $scope.list.memberIdx++;
      }
      return;
    }
    screenNameTolowerCased = newData.toLowerCase();
    return $scope.list.members = $scope.list.amatsukaMemberList.filter(function(element, index, array) {
      return element.screen_name.toLowerCase().indexOf(screenNameTolowerCased) !== -1;
    });
  });
}]);

angular.module("myApp.controllers").controller("UserCtrl", ["$scope", "$location", "ConfigService", "TweetService", "ListService", "Tweets", function($scope, $location, ConfigService, TweetService, ListService, Tweets) {
  $scope.isOpened = false;
  $scope.config = {};
  $scope.$on('userData', function(event, args) {
    if (!$scope.isOpened) {
      return;
    }
    $scope.user = ListService.normalizeMember(args);
    $scope.listIdStr = ListService.amatsukaList.data.id_str;
  });
  $scope.$on('tweetData', function(event, args) {
    var maxId, tweetsNormalized;
    if (!$scope.isOpened) {
      return;
    }
    ConfigService.getFromDB().then(function(data) {
      return $scope.config = data;
    });
    maxId = _.last(args) != null ? TweetService.decStrNum(_.last(args).id_str) : 0;
    tweetsNormalized = TweetService.normalizeTweets(args);
    $scope.tweets = new Tweets(tweetsNormalized, maxId, 'user_timeline', $scope.user.id_str);
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
    TweetService.applyFollowStatusChange($scope.tweets.items, args);
  });
}]);

angular.module("myApp.directives").directive('copyMember', ["$rootScope", "toaster", "TweetService", function($rootScope, toaster, TweetService) {
  return {
    restrict: 'A',
    scope: {
      sourceList: '='
    },
    link: function(scope, element, attrs) {
      return element.on('click', function(event) {
        if (element.hasClass('disabled')) {
          return;
        }
        if (window.confirm('コピーしてもよろしいですか？')) {
          element.addClass('disabled');
          toaster.pop('wait', "Now Copying ...", '', 0, 'trustedHtml');
          return scope.sourceList.copyMember2AmatsukaList().then(function(data) {
            element.removeClass('disabled');
            toaster.clear();
            $rootScope.$broadcast('list:copyMember', data);
            return toaster.pop('success', "Finished copy member", '', 2000, 'trustedHtml');
          });
        }
      });
    }
  };
}]);

angular.module("myApp.directives").directive('resize', ["$timeout", "$rootScope", "$window", "ConfigService", function($timeout, $rootScope, $window, ConfigService) {
  return {
    link: function() {
      var timer;
      timer = false;
      return angular.element($window).on('load resize', function(e) {
        if (timer) {
          $timeout.cancel(timer);
        }
        timer = $timeout(function() {
          var cW, html;
          html = angular.element(document).find('html');
          cW = html[0].clientWidth;
          console.log('broadCast resize ', cW);
          return ConfigService.get().then(function(config) {
            var layoutType;
            console.log('config = ', config);
            layoutType = cW < 700 ? 'list' : config.isTileLayout ? 'tile' : 'grid';
            return $rootScope.$broadcast('resize::resize', {
              layoutType: layoutType
            });
          });
        }, 200);
      });
    }
  };
}]);

angular.module('myApp.directives').directive('showStatuses', ["$compile", "$swipe", "TweetService", "WindowScrollableSwitcher", "ZoomImageViewer", function($compile, $swipe, TweetService, WindowScrollableSwitcher, ZoomImageViewer) {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      return element.on('click', function(event) {
        var bindEvents, cleanup, getImgIdx, getImgIdxBySrc, html, imageLayer, imageLayerContainer, imgIdx, next, prev, showPrevNextElement, showTweetInfomation, switchImage, tweet, upsertPictCounterElement, zoomImageViewer;
        WindowScrollableSwitcher.disableScrolling();
        tweet = null;
        imgIdx = 0;
        zoomImageViewer = new ZoomImageViewer();
        zoomImageViewer.pipeLowToHighImage(attrs.imgSrc, attrs.imgSrc.replace(':small', '') + ':orig');
        html = angular.element(document).find('html');
        imageLayer = angular.element(document).find('.image-layer');
        imageLayerContainer = angular.element(document).find('.image-layer__container');
        imageLayerContainer.on('click', function() {
          return cleanup();
        });
        next = null;
        prev = null;
        TweetService.showStatuses({
          tweetIdStr: attrs.tweetIdStr
        }).then(function(data) {
          tweet = data.data;
          bindEvents();
          imgIdx = getImgIdxBySrc(tweet, attrs.imgSrc.replace(':small', ''));
          showTweetInfomation(tweet, imgIdx);
          return upsertPictCounterElement(tweet, imgIdx);
        });
        upsertPictCounterElement = function(tweet, imgIdx) {
          var imageLayerCounter, totalPictNumber;
          totalPictNumber = tweet.extended_entities.media.length;
          imageLayerCounter = angular.element(document).find('.image-layer__counter');
          if (imageLayerCounter.length) {
            imageLayerCounter.html("" + (imgIdx + 1) + " / " + totalPictNumber);
            return;
          }
          html = "<div class=\"image-layer__counter\">\n  " + (imgIdx + 1) + " / " + totalPictNumber + "\n</div>";
          return imageLayerContainer.after(html);
        };
        showPrevNextElement = function() {
          html = "<div class=\"image-layer__prev\">\n  <i class=\"fa fa-angle-left fa-2x feeding-arrow\"></i>\n</div>\n<div class=\"image-layer__next\">\n  <i class=\"fa fa-angle-right fa-2x feeding-arrow feeding-arrow-right__patch\"></i>\n</div>";
          return imageLayerContainer.after(html);
        };
        showTweetInfomation = function(tweet, imgIdx) {
          var imageLayerCaptionHtml, item;
          imageLayerCaptionHtml = "<div class=\"image-layer__caption\">\n  <div class=\"timeline__footer\">\n    <div class=\"timeline__footer__contents\">\n      <div class=\"timeline__footer__controls\">\n        <a href=\"" + tweet.extended_entities.media[imgIdx].expanded_url + "\" target=\"_blank\">\n          <i class=\"fa fa-twitter icon-twitter\"></i>\n        </a>\n        <i class=\"fa fa-retweet icon-retweet\" tweet-id-str=\"" + tweet.id_str + "\" retweeted=\"" + tweet.retweeted + "\" retweetable=\"retweetable\"></i>\n        <i class=\"fa fa-heart icon-heart\" tweet-id-str=\"" + tweet.id_str + "\" favorited=\"" + tweet.favorited + "\" favoritable=\"favoritable\"></i>\n        <a>\n          <i class=\"fa fa-download\" data-url=\"" + tweet.extended_entities.media[imgIdx].media_url_https + ":orig\" filename=\"" + tweet.user.screen_name + "_" + tweet.id_str + "\" download-from-url=\"download-from-url\"></i>\n        </a>\n      </div>\n    </div>\n  </div>\n</div>";
          if (_.isEmpty(imageLayer.html())) {
            return;
          }
          item = $compile(imageLayerCaptionHtml)(scope).hide().fadeIn(300);
          return imageLayer.append(item);
        };
        getImgIdxBySrc = function(tweet, src) {
          return _.findIndex(tweet.extended_entities.media, {
            'media_url_https': src
          });
        };
        getImgIdx = function(dir, originalIdx) {
          if (dir === 'next') {
            return (originalIdx + 1) % tweet.extended_entities.media.length;
          }
          if (dir === 'prev') {
            originalIdx = originalIdx - 1;
            if (originalIdx < 0) {
              return tweet.extended_entities.media.length - 1;
            } else {
              return originalIdx;
            }
          }
        };
        switchImage = function(dir) {
          var src;
          imgIdx = getImgIdx(dir, imgIdx);
          src = tweet.extended_entities.media[imgIdx].media_url_https;
          console.log('switchImage');
          console.log(imgIdx);
          console.log(src);
          upsertPictCounterElement(tweet, imgIdx);
          return zoomImageViewer.pipeLowToHighImage("" + src + ":small", "" + src + ":orig");
        };
        bindEvents = function() {
          var startCoords;
          Mousetrap.bind('d', function() {
            return angular.element(document).find('.image-layer__caption .fa-download').click();
          });
          Mousetrap.bind('f', function() {
            return angular.element(document).find('.image-layer__caption .icon-heart').click();
          });
          Mousetrap.bind('r', function() {
            return angular.element(document).find('.image-layer__caption .icon-retweet').click();
          });
          Mousetrap.bind('t', function() {
            return angular.element(document).find('.image-layer__caption .fa-twitter').click();
          });
          Mousetrap.bind(['esc', 'q'], function() {
            return cleanup();
          });
          if (tweet.extended_entities.media.length < 2) {
            return;
          }
          showPrevNextElement();
          next = angular.element(document).find('.image-layer__next');
          prev = angular.element(document).find('.image-layer__prev');
          next.on('click', function() {
            return switchImage('next');
          });
          prev.on('click', function() {
            return switchImage('prev');
          });
          Mousetrap.bind(['left', 'k'], function() {
            return switchImage('prev');
          });
          Mousetrap.bind(['right', 'j'], function() {
            return switchImage('next');
          });
          startCoords = {};
          $swipe.bind(zoomImageViewer.getImageLayerImg(), {
            'start': function(coords, event) {
              console.log('start');
              return startCoords = coords;
            },
            'move': function(coords, event) {
              return console.log('move');
            },
            'end': function(coords, event) {
              console.log('Math.abs(startCoords.y - coords.y) = ', Math.abs(startCoords.y - coords.y));
              if (Math.abs(startCoords.y - coords.y) === 0) {
                return;
              }
              if (startCoords.x > coords.x) {
                switchImage('next');
              } else {
                switchImage('prev');
              }
              return startCoords = {};
            },
            'cancel': function(coords, event) {
              console.log('cancel');
              return cleanup();
            }
          });
          return imageLayerContainer.on('wheel', function(e) {
            var dir;
            dir = e.originalEvent.wheelDelta >= 0 ? 'prev' : 'next';
            return switchImage(dir);
          });
        };
        return cleanup = function() {
          Mousetrap.unbind(['left', 'right', 'esc', 'd', 'f', 'j', 'k', 'q', 'r', 't']);
          zoomImageViewer.getImageLayerImg().unbind('mousedown mousemove mouseup touchstart touchmove touchend touchcancel');
          imageLayer.html('');
          imageLayerContainer.html('');
          if (next != null) {
            next.remove();
          }
          if (prev != null) {
            prev.remove();
          }
          WindowScrollableSwitcher.enableScrolling();
          zoomImageViewer.cleanup();
          return zoomImageViewer = null;
        };
      });
    }
  };
}]);



angular.module("myApp.directives").directive('showUserSidebar', ["$rootScope", "TweetService", function($rootScope, TweetService) {
  return {
    restrict: 'A',
    scope: {
      twitterIdStr: '@'
    },
    link: function(scope, element, attrs) {
      var showUserSidebar;
      showUserSidebar = function() {
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
        var $document, body, domUserSidebar, domUserSidebarHeader, isOpenedSidebar, layer;
        $rootScope.$broadcast('isOpened', true);
        $document = angular.element(document);
        domUserSidebar = $document.find('.user-sidebar');
        domUserSidebarHeader = $document.find('.user-sidebar__header');
        isOpenedSidebar = 　domUserSidebar[0].className.indexOf('.user-sidebar--in') !== -1;
        if (isOpenedSidebar) {
          showUserSidebar();
          return;
        }

        /*
        初回(サイドバーは見えない状態が初期状態)
         */
        domUserSidebar.addClass('user-sidebar--in');
        domUserSidebarHeader.removeClass('user-sidebar__controll--out');
        body = $document.find('body');
        body.addClass('scrollbar-y-hidden');
        layer = $document.find('.layer');
        layer.addClass('fullscreen-overlay');
        showUserSidebar();
        return layer.on('click', function() {
          body.removeClass('scrollbar-y-hidden');
          layer.removeClass('fullscreen-overlay');
          domUserSidebar.removeClass('user-sidebar--in');
          domUserSidebarHeader.addClass('user-sidebar__controll--out');
          return $rootScope.$broadcast('isClosed', true);
        });
      });
    }
  };
}]);

var TermPaginationController;

angular.module("myApp.directives").directive('termPagination', function() {
  return {
    restrict: 'E',
    scope: {},
    template: "<div class=\"pagination__term\">\n  <div class=\"pagination__button\">\n    <a class=\"pagination__term--prev\" ng-click=\"$ctrl.paginate(-1)\"><</a>\n  </div>\n  <a class=\"pagination__term--active\">{{$ctrl.date}}   【{{$ctrl.total}}】</a>\n  <div class=\"pagination__button\">\n    <a class=\"pagination__term--next\" ng-click=\"$ctrl.paginate(1)\">></a>\n  </div>\n</div>",
    bindToController: {
      term: "=",
      total: "="
    },
    controller: TermPaginationController,
    controllerAs: "$ctrl"
  };
});

TermPaginationController = (function() {
  function TermPaginationController($scope, TimeService, TermPeginateDataServicve, URLParameterChecker) {
    var urlParameterChecker;
    this.$scope = $scope;
    this.TimeService = TimeService;
    this.TermPeginateDataServicve = TermPeginateDataServicve;
    urlParameterChecker = new URLParameterChecker();
    console.log('TermPaginationController ', urlParameterChecker.queryParams);
    if (_.isEmpty(urlParameterChecker.queryParams)) {
      urlParameterChecker.queryParams.date = moment().subtract(1, 'days').format('YYYY-MM-DD');
    }
    this.date = this.TimeService.normalizeDate('days', urlParameterChecker.queryParams.date);
    this.subscribe();
    this.bindKeyAction();
    this.$scope.$on('$destroy', (function(_this) {
      return function() {
        return _this.unbindKeyAction();
      };
    })(this));
  }

  TermPaginationController.prototype.bindKeyAction = function() {
    Mousetrap.bind(['ctrl+left'], (function(_this) {
      return function() {
        return _this.paginate(-1);
      };
    })(this));
    return Mousetrap.bind(['ctrl+right'], (function(_this) {
      return function() {
        return _this.paginate(1);
      };
    })(this));
  };

  TermPaginationController.prototype.unbindKeyAction = function() {
    return Mousetrap.unbind(['ctrl+left', 'ctrl+right']);
  };

  TermPaginationController.prototype.subscribe = function() {
    return this.$scope.$on('TermPeginateDataServicve::publish', (function(_this) {
      return function(event, args) {
        return _this.date = args.date;
      };
    })(this));
  };

  TermPaginationController.prototype.paginate = function(amount) {
    this.date = this.TimeService.changeDate('days', this.date, amount);
    this.TermPeginateDataServicve.publish({
      date: this.date
    });
    return this.$scope.$emit('termPagination::paginate', {
      date: this.date
    });
  };

  return TermPaginationController;

})();

TermPaginationController.$inject = ['$scope', 'TimeService', 'TermPeginateDataServicve', 'URLParameterChecker'];

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
    template: '<span class="label label-default timeline__header__label">{{content}}</span>',
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
            console.log('E followable createListsMembers data', data);
            return TweetService.collectProfile({
              twitterIdStr: scope.twitterIdStr
            });
          }).then(function(data) {
            return console.log(data);
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
            console.log(data);
            ListService.removeMember(scope.twitterIdStr);
            $rootScope.$broadcast('list:removeMember', data);
            return scope.isProcessing = false;
          });
        }
        if (scope.followStatus === false) {
          element[0].innerText = 'フォロー解除';
          TweetService.createListsMembers(opts).then(function(data) {
            ListService.addMember(scope.twitterIdStr);
            $rootScope.$broadcast('addMember', scope.twitterIdStr);
            $rootScope.$broadcast('list:addMember', data);
            scope.isProcessing = false;
            return TweetService.collectProfile({
              twitterIdStr: scope.twitterIdStr
            });
          }).then(function(data) {
            return console.log(data);
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
        var $document, body, domUserSidebar, domUserSidebarHeader, isOpenedSidebar, layer;
        $rootScope.$broadcast('isOpened', true);
        $document = angular.element(document);
        domUserSidebar = $document.find('.user-sidebar');
        domUserSidebarHeader = $document.find('.user-sidebar__header');
        isOpenedSidebar = 　domUserSidebar[0].className.indexOf('.user-sidebar--in') !== -1;
        if (isOpenedSidebar) {
          showTweet();
          return;
        }

        /*
        初回(サイドバーは見えない状態が初期状態)
         */
        domUserSidebar.addClass('user-sidebar--in');
        domUserSidebarHeader.removeClass('user-sidebar__controll--out');
        body = $document.find('body');
        body.addClass('scrollbar-y-hidden');
        layer = $document.find('.layer');
        layer.addClass('fullscreen-overlay');
        showTweet();
        return layer.on('click', function() {
          body.removeClass('scrollbar-y-hidden');
          layer.removeClass('fullscreen-overlay');
          domUserSidebar.removeClass('user-sidebar--in');
          domUserSidebarHeader.addClass('user-sidebar__controll--out');
          return $rootScope.$broadcast('isClosed', true);
        });
      });
    }
  };
}]);

angular.module("myApp.directives").directive("zoomImage", ["$compile", "$rootScope", "TweetService", "GetterImageInfomation", function($compile, $rootScope, TweetService, GetterImageInfomation) {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      return element.on('click', function() {
        var containerHTML, imageLayer, imageLayerContainer, imageLayerImg, imageLayerLoading;
        imageLayer = angular.element(document).find('.image-layer');
        containerHTML = "<div class=\"image-layer__container\">\n  <img class=\"image-layer__img\"/>\n  <div class=\"image-layer__loading\">\n    <img src=\"./images/loaders/tail-spin.svg\" />\n  </div>\n</div>";
        imageLayer.html(containerHTML);
        imageLayer.addClass('image-layer__overlay');
        imageLayerImg = angular.element(document).find('.image-layer__img');
        imageLayerLoading = angular.element(document).find('.image-layer__loading');
        imageLayerImg.hide();
        imageLayerImg.attr('src', ("" + attrs.imgSrc).replace(':small', ':orig')).load(function() {
          var direction;
          direction = GetterImageInfomation.getWideDirection(imageLayerImg);
          imageLayerImg.addClass("image-layer__img-" + direction + "-wide");
          imageLayerLoading.remove();
          return imageLayerImg.fadeIn(1);
        });
        imageLayerContainer = angular.element(document).find('.image-layer__container');
        return imageLayerContainer.on('click', function() {
          imageLayer.html('');
          return imageLayer.removeClass('image-layer__overlay');
        });
      });
    }
  };
}]);

angular.module("myApp.factories").factory('AmatsukaList', ["TweetService", "ListService", function(TweetService, ListService) {
  var AmatsukaList;
  AmatsukaList = (function() {
    function AmatsukaList(name) {
      this.name = name;
      this.isLast = false;
      this.count = 20;
      this.members = [];
      this.memberIdx = 0;
      this.idStr = (JSON.parse(localStorage.getItem('amatsukaList')) || {}).id_str;
      this.amatsukaMemberList = ListService.normalizeMembers(JSON.parse(localStorage.getItem('amatsukaFollowList'))) || [];
      this.amatsukaMemberLength = this.amatsukaMemberList.length;
    }

    AmatsukaList.prototype.updateAmatsukaList = function() {
      return ListService.update().then((function(_this) {
        return function(users) {
          _this.idstr = ListService.amatsukaList.data.id_str;
          _this.amatsukaMemberList = ListService.normalizeMembers(users);
          _this.amatsukaMemberLength = _this.amatsukaMemberList.length;
          _this.length = _this.amatsukaMemberLength;
          _this.isLast = true;
          _this.members = _this.amatsukaMemberList;
          return console.log(_this.members);
        };
      })(this));
    };

    AmatsukaList.prototype.loadMoreMember = function() {
      if (this.isLast) {
        return;
      }
      this.members = this.members.concat(this.amatsukaMemberList.slice(this.memberIdx, this.memberIdx + this.count));
      this.memberIdx += this.count;
      if (this.memberIdx > this.amatsukaMemberLength) {
        this.isLast = true;
      }
    };

    return AmatsukaList;

  })();
  return AmatsukaList;
}]);

angular.module("myApp.factories").factory('BlackUserList', ["TweetService", "BlackUserListService", function(TweetService, BlackUserListService) {
  var BlackUserList;
  BlackUserList = (function() {
    function BlackUserList() {
      this.blockUserList = [];
      this.blockOpts = {
        method: 'blocks',
        type: 'list',
        cursor: -1
      };
    }

    BlackUserList.prototype.setBlockUserList = function() {
      return TweetService.getViaAPI(this.blockOpts).then((function(_this) {
        return function(blocklist) {
          if (data.error != null) {
            reject(data.error);
          }
          console.log('blocklist', blocklist.data);
          _this.blockUserList = _this.blockUserList.concat(blocklist.data.users);
          if (blocklist.data.users.length === 0) {
            console.log('blockliist 全部読み終えた！！！');
            console.log(_this.blockUserList);
            localStorage.setItem('amatsuka.blockUserList', JSON.stringify(_this.blockUserList));
            BlackUserListService.block = _this.blockUserList;
            return;
          }
          _this.blockOpts.cursor = blocklist.data.next_cursor_str;
          return _this.setBlockUserList();
        };
      })(this))["catch"]((function(_this) {
        return function(err) {};
      })(this));
    };

    return BlackUserList;

  })();
  return BlackUserList;
}]);

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

angular.module("myApp.factories").factory('List', ["$q", "toaster", "TweetService", "ListService", "Member", function($q, toaster, TweetService, ListService, Member) {
  var List;
  List = (function(_super) {
    __extends(List, _super);

    function List(name, idStr) {
      List.__super__.constructor.call(this, name, idStr);
    }

    List.prototype.loadMember = function() {
      return TweetService.getListsMembers({
        listIdStr: this.idStr,
        count: 1000
      }).then((function(_this) {
        return function(data) {
          return _this.members = ListService.normalizeMembersForCopy(data.data.users);
        };
      })(this));
    };

    return List;

  })(Member);
  return List;
}]);

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module("myApp.factories").factory('Mao', ["$q", "$httpParamSerializer", "ListService", "MaoService", "TweetService", function($q, $httpParamSerializer, ListService, MaoService, TweetService) {
  var Mao;
  Mao = (function() {
    function Mao(date) {
      this.date = date;
      this.normalizeTweets = __bind(this.normalizeTweets, this);
      this.busy = false;
      this.isLast = false;
      this.limit = 20;
      this.skip = 0;
      this.items = [];
      this.isAuthenticatedWithMao = true;
    }

    Mao.prototype.normalizeTweets = function(tweets) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          var pictTweetList, result, tweetsGroupBy, tweetsNormalized;
          tweets = tweets.map(function(item) {
            return item.tweet = JSON.parse(item.tweetStr);
          });
          tweetsNormalized = TweetService.normalizeTweets(tweets, ListService.amatsukaList.member);
          tweetsGroupBy = _(tweetsNormalized).groupBy(function(o) {
            return o.user.id_str;
          }).value();
          pictTweetList = _.values(tweetsGroupBy);
          result = pictTweetList.map(function(item) {
            return {
              user: item[0].user,
              pictTweetList: item
            };
          });
          console.log('pictTweetList = ', pictTweetList);
          result = result.map(function(item) {
            var pictList;
            pictList = _.flatten(item.pictTweetList.map(function(tweet) {
              return tweet.extended_entities.media.map(function(media) {
                return {
                  tweet: tweet,
                  media: media
                };
              });
            }));
            return {
              user: item.user,
              pictList: pictList
            };
          });
          console.log(result);
          return resolve(result);
        };
      })(this));
    };

    Mao.prototype.load = function() {
      var opts, qs;
      if (this.busy || this.isLast) {
        return;
      }
      this.busy = true;
      opts = {
        skip: this.skip,
        limit: this.limit,
        date: this.date
      };
      qs = $httpParamSerializer(opts);
      return MaoService.findByMaoTokenAndDate(qs).then((function(_this) {
        return function(data) {
          return _this.normalizeTweets(data.data);
        };
      })(this)).then((function(_this) {
        return function(normalizedTweets) {
          if (normalizedTweets.length === 0) {
            _this.busy = false;
            _this.isLast = true;
            return;
          }
          normalizedTweets.forEach(function(tweet) {
            return _this.items.push(tweet);
          });
          _this.skip += _this.limit;
          return _this.busy = false;
        };
      })(this))["catch"]((function(_this) {
        return function(err) {
          _this.isLast = true;
          _this.busy = false;
          return _this.isAuthenticatedWithMao = false;
        };
      })(this));
    };

    return Mao;

  })();
  return Mao;
}]);

angular.module("myApp.factories").factory('Member', ["$q", "toaster", "TweetService", "ListService", function($q, toaster, TweetService, ListService) {
  var Member;
  Member = (function() {
    function Member(name, idStr) {
      this.name = name;
      this.idStr = idStr;
      this.isLast = false;
      this.count = 20;
      this.nextCursor = -1;
      this.members = [];
      this.memberIdx = 0;
      this.amatsukaListIdStr = ListService.amatsukaList.data.id_str;
    }

    Member.prototype.loadMember = function() {
      return TweetService.getFollowingList({
        twitterIdStr: this.idStr,
        nextCursor: this.nextCursor,
        count: 200
      }).then((function(_this) {
        return function(data) {
          console.log(data);
          if (_.isEmpty(data.data.users)) {
            return;
          }
          console.log(data.data.next_cursor);
          _this.members = _this.members.concat(ListService.normalizeMembersForCopy(data.data.users));
          _this.nextCursor = data.data.next_cursor_str;
          if (data.data.next_cursor === 0) {
            return;
          }
          return _this.loadMember();
        };
      })(this));
    };

    Member.prototype.copyMember2AmatsukaList = function() {
      return $q((function(_this) {
        return function(resolve, reject) {
          var twitterIdStr;
          if (_this.members.length === 0) {
            return reject('member is nothing');
          }
          twitterIdStr = '';
          _.each(_this.members, function(user) {
            return twitterIdStr += "" + user.id_str + ",";
          });
          return TweetService.createAllListsMembers({
            listIdStr: _this.amatsukaListIdStr,
            twitterIdStr: twitterIdStr
          }).then(function(data) {
            console.log('copyMember2AmatsukaList ok', data);
            return resolve(data);
          })["catch"](function(e) {
            return reject(e);
          });
        };
      })(this));
    };

    return Member;

  })();
  return Member;
}]);

angular.module("myApp.factories").factory('Pict', ["$q", "toaster", "TweetService", function($q, toaster, TweetService) {
  var Pict;
  Pict = (function() {
    function Pict(name, idStr) {
      this.busy = false;
      this.isLast = false;
      this.limit = 10;
      this.skip = 0;
      this.items = [];
      this.numIllustorator = 0;
      this.numMaxSkip = 0;
      this.doneSkip = [];
    }

    Pict.prototype.randomAccess = function() {
      var skip;
      while (true) {
        skip = _.sample(_.range(this.numMaxSkip));
        if (!this.doneSkip.includes(skip) || this.doneSkip.length >= this.numMaxSkip) {
          break;
        }
      }
      this.doneSkip.push(skip);
      this.skip = skip * this.limit;
      TweetService.getPict({
        skip: this.skip,
        limit: this.limit
      }).then((function(_this) {
        return function(data) {
          _this.items = _this.items.concat(data);
          _this.skip += _this.limit;
          if (_this.doneSkip.length >= _this.numMaxSkip) {
            _this.isLast = true;
          }
          return _this.busy = false;
        };
      })(this));
    };

    Pict.prototype.load = function() {
      if (this.busy || this.isLast) {
        return;
      }
      this.busy = true;
      if (this.numIllustorator !== 0) {
        this.randomAccess();
        return;
      }
      return TweetService.getPictCount().then((function(_this) {
        return function(count) {
          _this.numIllustorator = count;
          _this.numMaxSkip = (_this.numIllustorator - 1) / _this.limit;
          return _this.randomAccess();
        };
      })(this));
    };

    return Pict;

  })();
  return Pict;
}]);

angular.module("myApp.factories").factory('TweetCountList', ["$q", "$httpParamSerializer", "MaoService", function($q, $httpParamSerializer, MaoService) {
  var TweetCountList;
  TweetCountList = (function() {
    function TweetCountList(date) {
      this.date = date;
      this.busy = false;
      this.isLast = false;
      this.limit = 20;
      this.skip = 0;
      this.maxCount = 1000;
      this.items = [];
      this.isAuthenticatedWithMao = true;
    }

    TweetCountList.prototype.load = function() {
      var opts, qs;
      if (this.busy || this.isLast) {
        return;
      }
      this.busy = true;
      opts = {
        skip: this.skip,
        limit: this.limit
      };
      qs = $httpParamSerializer(opts);
      return MaoService.aggregateTweetCount(qs).then((function(_this) {
        return function(tweetCountist) {
          console.log('aggregateTweetCount ==> ', tweetCountist);
          if (tweetCountist.data.length === 0) {
            _this.busy = false;
            _this.isLast = true;
            return;
          }
          if (_this.items.length === 0) {
            console.log('tweetCountist = ', tweetCountist);
            _this.maxCount = tweetCountist.data[0].postCount;
          }
          tweetCountist.data.map(function(tweet) {
            return _this.items.push(tweet);
          });
          _this.skip += _this.limit;
          return _this.busy = false;
        };
      })(this))["catch"]((function(_this) {
        return function(err) {
          _this.isLast = true;
          _this.busy = false;
          return _this.isAuthenticatedWithMao = false;
        };
      })(this));
    };

    return TweetCountList;

  })();
  return TweetCountList;
}]);

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module("myApp.factories").factory('Tweets', ["$http", "$q", "ToasterService", "TweetService", "ListService", function($http, $q, ToasterService, TweetService, ListService) {
  var Tweets;
  Tweets = (function() {
    function Tweets(items, maxId, type, twitterIdStr) {
      this.items = items;
      this.maxId = maxId != null ? maxId : void 0;
      this.type = type;
      this.twitterIdStr = twitterIdStr != null ? twitterIdStr : null;
      this.checkError = __bind(this.checkError, this);
      this.assignTweet = __bind(this.assignTweet, this);
      this.normalizeTweet = __bind(this.normalizeTweet, this);
      this.busy = false;
      this.isLast = false;
      this.method = null;
      this.count = 40;
    }

    Tweets.prototype.normalizeTweet = function(data) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          var itemsNormalized;
          if (data.error != null) {
            reject(data.error);
          }
          if (_.isEmpty(data.data)) {
            reject({
              statusCode: 10100
            });
          }
          _this.maxId = TweetService.decStrNum(_.last(data.data).id_str);
          console.time('normalize_tweets');
          itemsNormalized = TweetService.normalizeTweets(data.data, ListService.amatsukaList.member);
          console.timeEnd('normalize_tweets');
          return resolve(itemsNormalized);
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
      } else if (this.type === 'like') {
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
          }).then(function(itemsNormalized) {
            return _this.assignTweet(itemsNormalized);
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

angular.module("myApp.factories").factory('URLParameterChecker', ["URLParameterService", function(URLParameterService) {
  var URLParameterChecker;
  return URLParameterChecker = (function() {
    function URLParameterChecker() {
      this.urlResources = URLParameterService.parse();
      this.queryParams = URLParameterService.getQueryParams();
    }

    URLParameterChecker.prototype.checkURLResourceLength = function(allowableLength) {
      return URLParameterService.checkURLResourceLength(this.urlResources.length, allowableLength);
    };

    return URLParameterChecker;

  })();
}]);

angular.module("myApp.factories").factory('WindowScrollableSwitcher', function() {
  var WindowScrollableSwitcher;
  WindowScrollableSwitcher = (function() {
    function WindowScrollableSwitcher() {}

    WindowScrollableSwitcher.enableScrolling = function() {
      window.onscroll = function() {};
    };

    WindowScrollableSwitcher.disableScrolling = function() {
      var x, y;
      x = window.scrollX;
      y = window.scrollY;
      return window.onscroll = function() {
        return window.scrollTo(x, y);
      };
    };

    return WindowScrollableSwitcher;

  })();
  return WindowScrollableSwitcher;
});

angular.module("myApp.factories").factory('ZoomImageViewer', ["GetterImageInfomation", function(GetterImageInfomation) {
  var ZoomImageViewer;
  ZoomImageViewer = (function() {
    function ZoomImageViewer() {
      var containerHTML;
      this.imageLayer = angular.element(document).find('.image-layer');
      containerHTML = "<div class=\"image-layer__container\">\n  <img class=\"image-layer__img\"/>\n  <div class=\"image-layer__loading\">\n    <img src=\"./images/loaders/tail-spin.svg\" />\n  </div>\n</div>\n";
      this.imageLayer.html(containerHTML);
      this.imageLayer.addClass('image-layer__overlay');
      this.imageLayerImg = angular.element(document).find('.image-layer__img');
      this.imageLayerLoading = angular.element(document).find('.image-layer__loading');
    }

    ZoomImageViewer.prototype.getImageLayerImg = function() {
      return this.imageLayerImg;
    };

    ZoomImageViewer.prototype.setImageAndStyle = function(imgElement) {
      var direction;
      direction = GetterImageInfomation.getWideDirection(imgElement);
      return imgElement.addClass("image-layer__img-" + direction + "-wide");
    };

    ZoomImageViewer.prototype.pipeLowToHighImage = function(from, to) {
      this.imageLayerLoading.show();
      this.imageLayerImg.hide();
      this.imageLayerImg.removeClass();
      return this.imageLayerImg.attr('src', from).load((function(_this) {
        return function() {
          console.log('-> Middle');
          _this.imageLayerLoading.hide();
          _this.setImageAndStyle(_this.imageLayerImg);
          _this.imageLayerImg.fadeIn(1);
          _this.imageLayerImg.off('load');
          return _this.imageLayerImg.attr('src', to).load(function() {
            console.log('-> High');
            return _this.imageLayerImg.fadeIn(1);
          });
        };
      })(this));
    };

    ZoomImageViewer.prototype.cleanup = function() {
      this.imageLayerLoading.remove();
      return this.imageLayer.removeClass('image-layer__overlay');
    };

    return ZoomImageViewer;

  })();
  return ZoomImageViewer;
}]);

angular.module("myApp.services").service("AuthService", ["$http", function($http) {
  return {
    isAuthenticated: function() {
      return $http.get("/isAuthenticated");
    },
    status: {
      isAuthenticated: false
    },
    user: {}
  };
}]);

angular.module("myApp.services").service("BlackUserListService", function() {
  return {
    block: [],
    mute: []
  };
});

angular.module("myApp.services").service("ConfigService", ["$http", "$q", function($http, $q) {
  return {
    config: {},
    set: function(config) {
      return this.config = config;
    },
    get: function() {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          console.log('get @pconfig = ', _this.config);
          if (!_.isEmpty(_this.config)) {
            return resolve(_this.config);
          }
          return _this.getFromDB().then(function(config) {
            console.log('get @getFromDB() config = ', config);
            _this.set(config);
            return resolve(config);
          });
        };
      })(this));
    },
    update: function() {
      localStorage.setItem('amatsuka.config', JSON.stringify(this.config));
    },
    init: function() {
      this.config = {
        includeRetweet: true,
        ngUsername: [],
        ngWord: []
      };
      return localStorage.setItem('amatsuka.config', JSON.stringify(this.config));
    },
    getFromDB: function() {
      return $q(function(resolve, reject) {
        return $http.get('/api/config').success(function(data) {
          console.log(data);
          console.log(_.isNull(data.data));
          if (_.isNull(data.data)) {
            return reject('Not found data');
          }
          return resolve(JSON.parse(data.data.configStr));
        }).error(function(data) {
          return reject(data || 'getFromDB Request failed');
        });
      });
    },
    save2DB: function() {
      return $q((function(_this) {
        return function(resolve, reject) {
          return $http.post('/api/config', {
            config: _this.config
          }).success(function(data) {
            return resolve(data);
          }).error(function(data) {
            return reject(data || 'save2DB Request failed');
          });
        };
      })(this));
    }
  };
}]);

angular.module("myApp.services").service('ConvertService', function() {
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

angular.module("myApp.services").service('DownloadService', ["$http", "ConvertService", function($http, ConvertService) {
  return {
    exec: function(url, filename, idx) {
      return $http.post('/api/download', {
        url: url
      }).success((function(_this) {
        return function(data) {
          var blob, ext;
          blob = ConvertService.base64toBlob(data.base64Data);
          ext = /media\/.*\.(png|jpg|jpeg):orig/.exec(url)[1];
          filename = "" + filename + "_" + idx + "." + ext;
          return _this.saveAs(blob, filename);
        };
      })(this));
    },
    saveAs: function(blob, filename) {
      var a;
      if (navigator.appVersion.toString().indexOf('.NET') > 0) {
        return window.navigator.msSaveBlob(blob, filename);
      } else {
        a = document.createElement('a');
        document.body.appendChild(a);
        a.style = 'display: none';
        a.href = window.URL.createObjectURL(blob);
        a.download = filename;
        return a.click();
      }
    }
  };
}]);

angular.module('myApp.services').service('GetterImageInfomation', function() {
  return {
    getWideDirection: function(imgElement) {
      var cH, cH_cW_percent, cW, direction, h, h_w_percent, html, w;
      html = angular.element(document).find('html');
      h = imgElement[0].naturalHeight;
      w = imgElement[0].naturalWidth;
      h_w_percent = h / w * 100;
      cH = html[0].clientHeight;
      cW = html[0].clientWidth;
      cH_cW_percent = cH / cW * 100;
      return direction = h_w_percent - cH_cW_percent >= 0 ? 'h' : 'w';
    }
  };
});

angular.module("myApp.services").service("ListService", ["$http", "$q", "AuthService", "TweetService", function($http, $q, AuthService, TweetService) {
  return {
    amatsukaList: {
      data: [],
      member: {}
    },
    registerMember2LocalStorage: function() {
      localStorage.setItem('amatsukaFollowList', JSON.stringify(this.amatsukaList.member));
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
    normalizeMembers: function(members) {
      return _.each(members, function(member) {
        member.followStatus = true;
        member.description = TweetService.activateLink(member.description);
        member.profile_image_url_https = TweetService.iconBigger(member.profile_image_url_https);
      });
    },
    changeFollowStatusAllMembers: function(members, bool) {
      return _.map(members, function(member) {
        member.followStatus = bool;
        return member;
      });
    },

    /*
     * 短縮URLの復元
     * followStatusの代入
     * Bioに含まれるリンクをハイパーリンク化
     * アイコン画像を大きいものに差し替え
     */
    normalizeMember: function(member) {
      var expandedUrlListInDescription, expandedUrlListInUrl;
      expandedUrlListInDescription = TweetService.getExpandedURLFromDescription(member.entities);
      expandedUrlListInUrl = TweetService.getExpandedURLFromURL(member.entities);
      _.each(expandedUrlListInDescription, function(urls) {
        member.description = member.description.replace(urls.url, urls.expanded_url);
      });
      _.each(expandedUrlListInUrl, function(urls) {
        member.url = member.url.replace(urls.url, urls.expanded_url);
      });
      member.followStatus = this.isFollow(member);
      member.description = TweetService.activateLink(member.description);
      member.profile_image_url_https = TweetService.iconBigger(member.profile_image_url_https);
      return member;
    },

    /*
     * 既存のリストからAmatsukaListへコピーするメンバーの属性をあるべき姿に正す(?)
     */
    normalizeMembersForCopy: function(members) {
      return _.each(members, (function(_this) {
        return function(member) {
          member.followStatus = _this.isFollow(member);
          member.isPermissionCopy = true;
          member.profile_image_url_https = TweetService.iconBigger(member.profile_image_url_https);
        };
      })(this));
    },
    update: function() {
      return TweetService.getListsList({
        twitterIdStr: AuthService.user._json.id_str
      }).then((function(_this) {
        return function(data) {
          console.log('UPDATE!! ', data.data);
          _this.amatsukaList.data = _.findWhere(data.data, {
            'full_name': "@" + AuthService.user.username + "/amatsuka"
          });
          console.log('update: @amatsukaList.data = ', _this.amatsukaList.data);
          localStorage.setItem('amatsukaList', JSON.stringify(_this.amatsukaList.data));
          return TweetService.getListsMembers({
            listIdStr: _this.amatsukaList.data.id_str
          });
        };
      })(this)).then((function(_this) {
        return function(data) {
          _this.amatsukaList.member = data.data.users;
          localStorage.setItem('amatsukaFollowList', JSON.stringify(_this.amatsukaList.member));
          return data.data.users;
        };
      })(this));
    },
    init: function() {
      return TweetService.createLists({
        name: 'Amatsuka',
        mode: 'private'
      }).then((function(_this) {
        return function(data) {
          var params;
          _this.amatsukaList.data = data.data;
          localStorage.setItem('amatsukaList', JSON.stringify(data.data));
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
          localStorage.setItem('amatsukaFollowList', JSON.stringify(data.data.users));
          return data.data.users;
        };
      })(this));
    },
    getAmatsukaList: function() {
      return $q((function(_this) {
        return function(resolve, reject) {
          console.log('isSameAmatsukaList AuthService.user._json.id_str = ', AuthService.user._json.id_str);
          return TweetService.getListsList({
            twitterIdStr: AuthService.user._json.id_str
          }).then(function(data) {
            var ownLists;
            ownLists = data.data;
            console.log('lists = ', ownLists);
            return resolve(_.findWhere(ownLists, {
              'full_name': "@" + AuthService.user.username + "/amatsuka"
            }) || {
              id_str: null
            });
          });
        };
      })(this));
    },
    isSameAmatsukaList: function() {
      return $q((function(_this) {
        return function(resolve, reject) {
          return _this.getAmatsukaList().then(function(newList) {
            var oldList;
            oldList = JSON.parse(localStorage.getItem('amatsukaList')) || {};
            return resolve(oldList.id_str === newList.id_str);
          })["catch"](function(error) {
            console.log('listService isSameAmatsukaList = ', error);
            return reject(error);
          });
        };
      })(this));
    },
    hasListData: function() {
      return !(_.isEmpty(this.amatsukaList.data) && _.isEmpty(this.amatsukaList.member));
    }
  };
}]);

angular.module("myApp.services").service("MaoService", ["$http", function($http) {
  return {
    findByMaoTokenAndDate: function(qs) {
      return $http.get("/api/mao?" + qs);
    },
    countTweetByMaoTokenAndDate: function(qs) {
      return $http.get("/api/mao/tweets/count?" + qs);
    },
    aggregateTweetCount: function(qs) {
      return $http.get("/api/mao/stats/tweet/count?" + qs);
    }
  };
}]);

angular.module("myApp.services").service("StatService", ["$http", "$q", function($http, $q) {}]);

angular.module("myApp.services").service("TermPeginateDataServicve", ["$rootScope", function($rootScope) {
  return {
    publish: function(params) {
      return $rootScope.$broadcast('TermPeginateDataServicve::publish', params);
    }
  };
}]);

angular.module("myApp.services").service("TimeService", function() {
  return {
    normalizeDate: function(term, date) {
      switch (term) {
        case 'days':
          return moment(date).format('YYYY-MM-DD');
        case 'weeks':
          return moment(date).format('YYYY-MM-DD');
        case 'month':
          return moment(date).date('1').format('YYYY-MM-DD');
        default:
          return moment(date).format('YYYY-MM-DD');
      }
    },
    changeDate: function(term, date, amount) {
      switch (term) {
        case 'days':
          return moment(date).add(amount, 'days').format('YYYY-MM-DD');
        case 'weeks':
          return moment(date).add(amount, 'weeks').format('YYYY-MM-DD');
        case 'month':
          return moment(date).add(amount, 'months').date('1').format('YYYY-MM-DD');
        default:
          return moment().format('YYYY-MM-DD');
      }
    }
  };
});

angular.module("myApp.services").service('ToasterService', ["toaster", function(toaster) {
  return {
    success: function(notify) {
      console.log(notify.title);
      return toaster.pop('success', notify.title, notify.text, 2000, 'trustedHtml');
    },
    warning: function(notify) {
      console.log(notify.title);
      return toaster.pop('warning', notify.title, notify.text, 2000, 'trustedHtml');
    }
  };
}]);

angular.module("myApp.services").service("TweetService", ["$http", "$httpParamSerializer", "$q", "$injector", "BlackUserListService", "ConfigService", "ToasterService", "toaster", function($http, $httpParamSerializer, $q, $injector, BlackUserListService, ConfigService, ToasterService, toaster) {
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
    normalizeTweets: function(tweets) {
      var ListService;
      console.log(tweets);
      ListService = $injector.get('ListService');
      return _.map(tweets, (function(_this) {
        return function(tweet) {
          var isRT;
          isRT = _.has(tweet, 'retweeted_status');
          tweet.isRT = isRT;
          tweet.followStatus = ListService.isFollow(tweet, isRT);
          tweet.text = _this.expandTweetUrl(tweet, isRT);
          tweet.time = _this.fromNow(_this.get(tweet, 'tweet.created_at', false));
          tweet.retweetNum = _this.get(tweet, 'tweet.retweet_count', isRT);
          tweet.favNum = _this.get(tweet, 'tweet.favorite_count', isRT);
          tweet.tweetIdStr = _this.get(tweet, 'tweet.id_str', isRT);
          tweet.sourceUrl = _this.get(tweet, 'display_url', isRT);
          tweet.picUrlList = _this.get(tweet, 'media_url_https:small', isRT);
          tweet.picOrigUrlList = _this.get(tweet, 'media_url_https:orig', isRT);
          tweet.video_url = _this.get(tweet, 'video_url', isRT);
          tweet.fileName = _this.get(tweet, 'screen_name', isRT) + '_' + _this.get(tweet, 'tweet.id_str', isRT);
          tweet.user.profile_image_url_https = _this.iconBigger(tweet.user.profile_image_url_https);
          return tweet;
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
        case 'media_url_https:small':
          return _.map(t.extended_entities.media, function(media) {
            return media.media_url_https + ':small';
          });
        case 'video_url':
          return (_ref5 = t.extended_entities) != null ? (_ref6 = _ref5.media[0]) != null ? (_ref7 = _ref6.video_info) != null ? _ref7.variants[0].url : void 0 : void 0 : void 0;
        case 'name':
          return t.user.name;
        case 'profile_banner_url':
          return t.user.profile_banner_url;
        case 'profile_image_url':
          return t.user.profile_image_url;
        case 'profile_image_url_https':
          return t.user.profile_image_url_https;
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
    expandTweetUrl: function(tweet, isRT) {
      var expandedUrlListInTweet;
      tweet.text = this.get(tweet, 'text', isRT);
      expandedUrlListInTweet = this.getExpandedURLFromTweet(tweet.entities);
      _.each(expandedUrlListInTweet, (function(_this) {
        return function(urls) {
          tweet.text = tweet.text.replace(urls.url, urls.expanded_url);
        };
      })(this));
      tweet.text = this.activateLink(tweet.text);
      return tweet.text;
    },
    getExpandedURLFromTweet: function(entities) {
      if (!_.has(entities, 'urls')) {
        return '';
      }
      return entities.urls;
    },
    getExpandedURLFromURL: function(entities) {
      if (!_.has(entities, 'url')) {
        return '';
      }
      return entities.url.urls;
    },
    getExpandedURLFromDescription: function(entities) {
      if (!_.has(entities, 'description')) {
        return '';
      }
      if (!_.has(entities.description, 'urls')) {
        return '';
      }
      return entities.description.urls;
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
    collectProfile: function(params) {
      return $q(function(resolve, reject) {
        return $http.post('/api/collect/profile', params).success(function(data) {
          return resolve(data);
        }).error(function(data) {
          return reject(data);
        });
      });
    },
    getPict: function(params) {
      return $q(function(resolve, reject) {
        return $http.get("/api/collect/" + params.skip + "/" + params.limit).success(function(data) {
          return resolve(data);
        }).error(function(data) {
          return reject(data);
        });
      });
    },
    getPictCount: function() {
      return $q(function(resolve, reject) {
        return $http.get("/api/collect/count").success(function(data) {
          return resolve(data.count);
        }).error(function(data) {
          return reject(data);
        });
      });
    },
    getAllPict: function(params) {
      console.log('getAllPict params = ', params);
      return $q((function(_this) {
        return function(resolve, reject) {
          var assignUserAllPict, maxId, userAllPict;
          userAllPict = [];
          maxId = maxId || 0;
          assignUserAllPict = function() {
            return _this.getUserTimeline({
              twitterIdStr: params.twitterIdStr,
              maxId: maxId,
              count: 200,
              isIncludeRetweet: params.isIncludeRetweet
            }).then(function(data) {
              if (_.isUndefined(data.data)) {
                toaster.pop('error', 'API制限。15分お待ち下さい。');
                return resolve(userAllPict);
              }
              if (data.data.length === 0) {
                toaster.pop('success', '最後まで読み終えました。');
                return resolve(userAllPict);
              }
              maxId = _this.decStrNum(data.data[data.data.length - 1].id_str);
              _.each(data.data, function(tweet) {
                tweet.totalNum = tweet.retweet_count + tweet.favorite_count;
                tweet.tweetIdStr = tweet.id_str;
              });
              userAllPict = userAllPict.concat(data.data);
              return assignUserAllPict();
            });
          };
          return assignUserAllPict();
        };
      })(this));
    },
    checkError: function(statusCode) {
      console.log(statusCode);
      switch (statusCode) {
        case 429:
          ToasterService.warning({
            title: 'API制限',
            text: '15分お待ちください'
          });
      }
    },

    /*
     * $httpのerrorメソッドは、サーバーがエラーを返したとき(404とか、500)であって、
     * TwitterAPIがAPI制限とかのエラーを返したときはsuccessメソッドの方へ渡されるため、
     * その中でresolve, rejectの分岐を行う
     */
    getViaAPI: function(params) {
      var qs;
      if (params == null) {
        params = {};
      }
      qs = $httpParamSerializer(params);
      return $q(function(resolve, reject) {
        return $http.get("/api/twitter?" + qs).success(function(data) {
          return resolve(data);
        }).error(function(data) {
          return reject(data);
        });
      });
    },

    /*
    List
     */
    getListsList: function(params) {
      return $q((function(_this) {
        return function(resolve, reject) {
          return $http.get("/api/lists/list/" + params.twitterIdStr).success(function(data) {
            console.log(data);
            if (_.has(data, 'error')) {
              _this.checkError(data.error.statusCode);
              return reject(data);
            }
            return resolve(data);
          }).error(function(data) {
            return reject(data);
          });
        };
      })(this));
    },
    createLists: function(params) {
      return $q(function(resolve, reject) {
        return $http.post('/api/lists/create', params).success(function(data) {
          return resolve(data);
        }).error(function(data) {
          return reject(data);
        });
      });
    },
    getListsMembers: function(params) {
      return $q(function(resolve, reject) {
        return $http.get("/api/lists/members/" + params.listIdStr + "/" + params.count).success(function(data) {
          return resolve(data);
        }).error(function(data) {
          return reject(data);
        });
      });
    },
    getListsStatuses: function(params) {
      return $q(function(resolve, reject) {
        return $http.get("/api/lists/statuses/" + params.listIdStr + "/" + params.maxId + "/" + params.count).success(function(data) {
          return resolve(data);
        }).error(function(data) {
          return reject(data);
        });
      });
    },
    createListsMembers: function(params) {
      return $q(function(resolve, reject) {
        return $http.post("/api/lists/members/create", params).success(function(data) {
          return resolve(data);
        }).error(function(data) {
          return reject(data);
        });
      });
    },
    createAllListsMembers: function(params) {
      return $q(function(resolve, reject) {
        return $http.post("/api/lists/members/create_all", params).success(function(data) {
          return resolve(data);
        }).error(function(data) {
          return reject(data);
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
        return $http.get("/api/timeline/" + params.twitterIdStr + "/" + params.maxId + "/" + params.count + "?isIncludeRetweet=" + params.isIncludeRetweet).success(function(data) {
          return resolve(data);
        }).error(function(data) {
          return reject(data);
        });
      });
    },

    /*
    Follow
     */
    getFollowingList: function(params) {
      return $q(function(resolve, reject) {
        return $http.get("/api/friends/list/" + params.twitterIdStr + "/" + params.count).success(function(data) {
          return resolve(data);
        });
      });
    },

    /*
    User
     */
    showStatuses: function(params) {
      return $q(function(resolve, reject) {
        return $http.get("/api/statuses/show/" + params.tweetIdStr).success(function(data) {
          return resolve(data);
        });
      });
    },

    /*
    User
     */
    showUsers: function(params) {
      return $q(function(resolve, reject) {
        return $http.get("/api/users/show/" + params.twitterIdStr + "/" + params.screenName).success(function(data) {
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

angular.module("myApp.services").service("URLParameterService", ["$location", function($location) {
  return {
    checkURLResourceLength: function(urlResourcesLength, allowableLength) {
      if (urlResourcesLength > allowableLength) {
        return $location.path('/');
      }
    },
    getQueryParams: function() {
      return $location.search();
    },
    parse: function() {
      return $location.path().split('/');
    }
  };
}]);

var MaoContainerController;

angular.module("myApp.directives").directive('maoContainer', function() {
  return {
    restrict: 'E',
    scope: {},
    template: "<ul class=\"nav nav-pills nav-stacked col-md-1 col-sm-2\">\n  <li ng-repeat=\"tab in $ctrl.tabs\" ng-class=\"{active: tab.active}\">\n    <a href=\"{{tab.href}}\" data-toggle=\"tab\" ng-click=\"$ctrl.select(tab.id)\" >{{tab.name}}</a>\n  </li>\n</ul>\n<div class=\"tab-content col-md-11 col-sm-10\">\n  <div id=\"tweets\" class=\"row tab-pane active\" ng-if=\"$ctrl.tabType == 'tweets'\">\n    <mao-list-container></mao-list-container>\n  </div>\n  <div id=\"stats\" class=\"row tab-pane\" ng-if=\"$ctrl.tabType == 'stats'\">\n    <mao-ranking-post-number></mao-ranking-post-number>\n  </div>\n</div>",
    bindToController: {},
    controllerAs: "$ctrl",
    controller: MaoContainerController
  };
});

MaoContainerController = (function() {
  function MaoContainerController() {
    this.tabs = [
      {
        'href': '#tweets',
        'id': 'tweets',
        'name': 'Tweets',
        'active': true
      }, {
        'href': '#stats',
        'id': 'stats',
        'name': 'Stats',
        'active': false
      }
    ];
    console.log(this.tabs);
    this.tabType = this.tabs[0].id;
  }

  MaoContainerController.prototype.select = function(id) {
    console.log(name);
    this.tabType = id;
    return this.tabs.forEach(function(tab) {
      console.log(tab.id);
      console.log(tab.id === id);
      tab.active = tab.id === id ? true : false;
      return console.log(tab);
    });
  };

  return MaoContainerController;

})();

var MaoListContoller;

angular.module("myApp.directives").directive('maoListContainer', function() {
  return {
    restrict: 'E',
    scope: {},
    template: "<dot-loader ng-if=\"!$ctrl.tweetList.items\" class=\"user-sidebar__contents--box-loading-init\">\n</dot-loader>\n<div ng-if=\"$ctrl.tweetList.isAuthenticatedWithMao\">\n\n  <div class=\"col-sm-12\">\n    <term-pagination total=\"$ctrl.tweetTotalNumber\"></term-pagination>\n  </div>\n\n  <div infinite-scroll=\"$ctrl.tweetList.load()\" infinite-scroll-distance=\"0\" class=\"col-sm-12 row-eq-height\">\n    <div ng-repeat=\"item in $ctrl.tweetList.items\" class=\"col-lg-4 col-md-6 col-sm-6 mao__tweet__container\">\n      <mao-tweet-article item=\"item\"></mao-tweet-article>\n    </div>\n  </div>\n\n  <div class=\"col-sm-12\">\n    <dot-loader ng-if=\"$ctrl.tweetList.busy\" class=\"infinitescroll-content\">\n    </dot-loader>\n    <div ng-show=\"$ctrl.tweetList.isLast\" class=\"text-center infinitescroll-content infinitescroll-message\">終わりです\n    </div>\n  </div>\n\n  <div class=\"col-sm-12 pagination__term__container--bottom\">\n    <term-pagination total=\"$ctrl.tweetTotalNumber\"></term-pagination>\n  </div>\n\n</div>\n<div ng-if=\"!$ctrl.tweetList.isAuthenticatedWithMao\" class=\"col-sm-12\">\n  <div class=\"infinitescroll-message\">\n    <p>MaoでのTwitter認証がされていないのでこの機能は利用できません。</p>\n    <p>MaoはAmatsukaのメンバーの人気の画像を毎日収集し、閲覧できる機能です。</p>\n    <p>認証は以下のリンク先で行えます</p>\n    <p>\n      <a href=\"https://ma0.herokuapp.com\" target=\"_blank\" class=\"mao__link\">\n        Mao\n        <i class=\"fa fa-external-link\"></i>\n      </a>\n    </p>\n  </div>\n</div>",
    bindToController: {},
    controllerAs: "$ctrl",
    controller: MaoListContoller
  };
});

MaoListContoller = (function() {
  function MaoListContoller($location, $httpParamSerializer, $scope, Mao, MaoService, URLParameterChecker, TimeService) {
    var qs, urlParameterChecker;
    this.$location = $location;
    this.$httpParamSerializer = $httpParamSerializer;
    this.$scope = $scope;
    this.Mao = Mao;
    this.MaoService = MaoService;
    this.TimeService = TimeService;
    urlParameterChecker = new URLParameterChecker();
    console.log(urlParameterChecker);
    if (_.isEmpty(urlParameterChecker.queryParams)) {
      urlParameterChecker.queryParams.date = moment().add(-1, 'days').format('YYYY-MM-DD');
    }
    this.date = moment(urlParameterChecker.queryParams.date).format('YYYY-MM-DD');
    this.tweetList = new this.Mao(this.date);
    this.tweetTotalNumber = 0;
    qs = this.$httpParamSerializer({
      date: this.date
    });
    this.MaoService.countTweetByMaoTokenAndDate(qs).then((function(_this) {
      return function(response) {
        return _this.tweetTotalNumber = response.data.count;
      };
    })(this));
    this.subscribe();
  }

  MaoListContoller.prototype.getTweet = function(newQueryParams) {
    this.date = this.TimeService.normalizeDate('days', newQueryParams.date);
    this.tweetList = new this.Mao(this.date);
    this.tweetList.load();
    return console.log('getTweet ', this.date);
  };

  MaoListContoller.prototype.subscribe = function() {
    this.$scope.$on('MaoStatusController::publish', (function(_this) {
      return function(event, args) {
        return _this.date = args.date;
      };
    })(this));
    return this.$scope.$on('termPagination::paginate', (function(_this) {
      return function(event, args) {
        console.log('termPagination::paginate on', args);
        _this.$location.search('date', args.date);
        _this.getTweet(args);
      };
    })(this));
  };

  return MaoListContoller;

})();

MaoListContoller.$inject = ['$location', '$httpParamSerializer', '$scope', 'Mao', 'MaoService', 'URLParameterChecker', 'TimeService'];

var MaoRankingPostNumber;

angular.module("myApp.directives").directive('maoRankingPostNumber', function() {
  return {
    restrict: 'E',
    scope: {},
    template: "<section infinite-scroll=\"$ctrl.tweetCountList.load()\" infinite-scroll-distance=\"0\" class=\"row fillbars\">\n\n  <div ng-repeat=\"item in $ctrl.tweetCountList.items\" class=\"fillbar\">\n\n    <div class=\"col-md-3 col-sm-3 col-xs-6 fillbar__user\">\n      <img ng-src=\"{{item.postedBy.icon}}\" twitter-id-str=\"{{item.postedBy.twitterIdStr}}\" show-tweet img-preload class=\"fade fillbar__icon\">\n      <span class=\"fillbar__screen-name clickable\" twitter-id-str=\"{{item.postedBy.twitterIdStr}}\"  show-tweet>{{item.postedBy.screenName}}</span>\n    </div>\n    <div class=\"col-md-9 col-sm-9 col-xs-6\">\n      <div class=\"progress\">\n        <div class=\"progress-bar\" role=\"progressbar\" aria-valuenow=\"60\" aria-valuemin=\"0\" aria-valuemax=\"100\" ng-style=\"{ 'width': item.postCount / $ctrl.tweetCountList.maxCount * 100 + '%'}\">\n          <span class=\"fillbar__count\">\n            {{item.postCount}}\n          </span>\n        </div>\n      </div>\n    </div>\n  </div>\n\n  <div class=\"col-sm-12\">\n    <dot-loader ng-if=\"$ctrl.tweetCountList.busy\" class=\"infinitescroll-content\">\n    </dot-loader>\n    <div ng-show=\"$ctrl.tweetCountList.isLast\" class=\"text-center infinitescroll-content infinitescroll-message\">終わりです\n    </div>\n  </div>\n\n</section>",
    bindToController: {},
    controllerAs: "$ctrl",
    controller: MaoRankingPostNumber
  };
});

MaoRankingPostNumber = (function() {
  function MaoRankingPostNumber(TweetCountList) {
    this.tweetCountList = new TweetCountList();
  }

  return MaoRankingPostNumber;

})();

MaoRankingPostNumber.$inject = ['TweetCountList'];

var MaoTweetArticleController;

angular.module("myApp.directives").directive('maoTweetArticle', function() {
  return {
    restrict: 'E',
    scope: {},
    template: "<div class=\"media mao__user\">\n  <a twitter-id-str=\"{{::$ctrl.item.user.id_str}}\" show-tweet=\"show-tweet\" class=\"pull-left\">\n    <img ng-src=\"{{::$ctrl.item.user.profile_image_url_https}}\" img-preload=\"img-preload\" class=\"mao__user__icon fade\"/>\n  </a>\n  <div class=\"media-body\">\n    <h4 class=\"media-heading\">\n      <span class=\"name\">{{::$ctrl.item.user.name}}</span>\n      <span twitter-id-str=\"{{::$ctrl.item.user.id_str}}\" show-tweet class=\"screen-name clickable\">@{{::$ctrl.item.user.screen_name}}</span>\n    </h4>\n  </div>\n</div>\n<div class=\"find__pict-tweet--container\">\n  <div>\n    <div ng-repeat=\"pict in $ctrl.item.pictList | limitTo: 12\" class=\"col-lg-6 col-md-4 col-sm-6 col-xs-6 mao__user__container\">\n      <div class=\"mao__pict__container\">\n        <img ng-src=\"{{::pict.media.media_url_https}}:small\" data-img-src=\"{{::pict.media.media_url_https}}\" tweet-id-str=\"{{::pict.tweet.id_str}}\" show-statuses=\"show-statuses\" img-preload class=\"fade find__pict-tweet--img\">\n      </div>\n    </div>\n  </div>\n</div>",
    bindToController: {
      item: '='
    },
    controllerAs: "$ctrl",
    controller: MaoTweetArticleController
  };
});

MaoTweetArticleController = (function() {
  function MaoTweetArticleController() {}

  return MaoTweetArticleController;

})();

var GridLayoutTweet;

angular.module("myApp.directives").directive('gridLayoutTweet', function() {
  return {
    restrict: 'E',
    scope: {},
    template: "<div class=\"timeline__post--header timeline__post--header--grid\">\n  <div class=\"timeline__post--header--info timeline__post--header--info--grid\">\n    <div class=\"timeline__post--header--link timeline__post--header--link--grid\">\n      <span twitter-id-str=\"{{::$ctrl.tweet.user.id_str}}\" show-tweet=\"show-tweet\" class=\"timeline__post--header--user timeline__post--header--user--grid clickable\">{{::$ctrl.tweet.user.screen_name}}\n      </span><span ng-if=\"$ctrl.tweet.retweeted_status\" class=\"timeline__post--header--rt_icon timeline__post--header--rt_icon--grid\"><i class=\"fa fa-retweet\"></i></span><a twitter-id-str=\"{{::$ctrl.tweet.retweeted_status.user.id_str}}\" show-tweet=\"show-tweet\" class=\"timeline__post--header--rt_source timeline__post--header--rt_source--grid\">{{::$ctrl.tweet.retweeted_status.user.screen_name}}\n      </a>\n      <followable ng-if=\"!$ctrl.tweet.followStatus\" list-id-str=\"{{$ctrl.listIdStr}}\" tweet=\"{{$ctrl.tweet}}\" follow-status=\"$ctrl.tweet.followStatus\">\n      </followable>\n    </div>\n  </div>\n  <div class=\"timeline__post--header--time\"><a href=\"https://{{::$ctrl.tweet.sourceUrl}}\" target=\"_blank\">{{::$ctrl.tweet.time}}\n    </a>\n  </div>\n</div>\n<div class=\"timeline__post--icon timeline__post--icon--grid\"><img ng-src=\"{{::$ctrl.tweet.user.profile_image_url_https}}\" img-preload=\"img-preload\" show-tweet=\"show-tweet\" twitter-id-str=\"{{::$ctrl.tweet.user.id_str}}\" class=\"fade\"/>\n</div>\n<div ng-repeat=\"picUrl in $ctrl.tweet.picUrlList\" class=\"timeline__post--image timeline__post--image--grid\">\n  <img ng-if=\"!$ctrl.tweet.video_url\" ng-src=\"{{::picUrl}}\" img-preload=\"img-preload\" zoom-image=\"zoom-image\" data-img-src=\"{{::picUrl}}\" class=\"fade\"/>\n  <video ng-if=\"$ctrl.tweet.video_url\" poster=\"{{::picUrl}}\" autoplay=\"autoplay\" loop=\"loop\" controls=\"controls\" muted=\"muted\">\n    <source ng-src=\"{{::$ctrl.tweet.video_url | trusted}}\" type=\"video/mp4\">\n    </source>\n  </video>\n</div>\n<div ng-if=\"!config.isShowOnlyImage\" class=\"timeline__post__text__container\">\n  <div ng-if=\"!$ctrl.tweet.retweeted_status\" ng-bind-html=\"$ctrl.tweet.text | newlines\" class=\"timeline__post--text timeline__post--text--grid\">\n  </div>\n  <div ng-if=\"$ctrl.tweet.retweeted_status\" class=\"timeline__post--blockquote timeline__post--blockquote--grid\">\n    <p><a twitter-id-str=\"{{::$ctrl.tweet.retweeted_status.user.id_str}}\" show-tweet=\"show-tweet\">{{::$ctrl.tweet.retweeted_status.user.screen_name}}\n      </a>\n    </p>\n    <blockquote>\n      <div ng-bind-html=\"$ctrl.tweet.text | newlines\" class=\"timeline__post--text\">\n      </div>\n    </blockquote>\n  </div>\n</div>\n<div class=\"timeline__post--footer timeline__post--footer--grid\">\n  <div class=\"timeline__post--footer--contents\">\n    <div class=\"timeline__post--footer--contents--controls\">\n      <i retweet-num=\"$ctrl.tweet.retweetNum\" retweeted=\"$ctrl.tweet.retweeted\" tweet-id-str=\"{{::$ctrl.tweet.tweetIdStr}}\" retweetable=\"retweetable\" class=\"fa fa-retweet icon-retweet\">{{$ctrl.tweet.retweetNum}}</i>\n      <i fav-num=\"$ctrl.tweet.favNum\" favorited=\"$ctrl.tweet.favorited\" tweet-id-str=\"{{::$ctrl.tweet.tweetIdStr}}\" favoritable=\"favoritable\" class=\"fa fa-heart icon-heart\">{{$ctrl.tweet.favNum}}</i>\n      <a>\n        <i data-url=\"{{::$ctrl.tweet.picOrigUrlList}}\" filename=\"{{::$ctrl.tweet.fileName}}\" download-from-url=\"download-from-url\" class=\"fa fa-download\"></i>\n      </a>\n    </div>\n  </div>\n</div>",
    bindToController: {
      tweet: "=",
      listIdStr: "="
    },
    controllerAs: "$ctrl",
    controller: GridLayoutTweet
  };
});

GridLayoutTweet = (function() {
  function GridLayoutTweet() {
    console.log(this);
  }

  return GridLayoutTweet;

})();

var ListLayoutTweet;

angular.module("myApp.directives").directive('listLayoutTweet', function() {
  return {
    restrict: 'E',
    scope: {},
    template: "\n<div class=\"timeline__post--header\">\n  <div class=\"timeline__post--header--info\">\n    <div class=\"timeline__post--header--link\">\n      <span twitter-id-str=\"{{::$ctrl.tweet.user.id_str}}\" show-tweet=\"show-tweet\" class=\"timeline__post--header--user clickable\">{{::$ctrl.tweet.user.screen_name}}\n      </span>\n      <span ng-if=\"$ctrl.tweet.retweeted_status\" class=\"timeline__post--header--rt_icon\">\n        <i class=\"fa fa-retweet\"></i>\n      </span>\n      <a twitter-id-str=\"{{::$ctrl.tweet.retweeted_status.user.id_str}}\" show-tweet=\"show-tweet\" class=\"timeline__post--header--rt_source\">{{::$ctrl.tweet.retweeted_status.user.screen_name}}\n      </a>\n      <followable ng-if=\"!$ctrl.tweet.followStatus\" list-id-str=\"{{$ctrl.listIdStr}}\" tweet=\"{{$ctrl.tweet}}\" follow-status=\"$ctrl.tweet.followStatus\">\n      </followable>\n    </div>\n  </div>\n  <div class=\"timeline__post--header--time\"><a href=\"https://{{::$ctrl.tweet.sourceUrl}}\" target=\"_blank\">{{::$ctrl.tweet.time}}\n    </a>\n  </div>\n</div>\n<div class=\"timeline__post--icon\"><img ng-src=\"{{::$ctrl.tweet.user.profile_image_url_https}}\" img-preload=\"img-preload\" show-tweet=\"show-tweet\" twitter-id-str=\"{{::$ctrl.tweet.user.id_str}}\" class=\"fade\"/>\n</div>\n<div ng-repeat=\"picUrl in $ctrl.tweet.picUrlList\" class=\"timeline__post--image\">\n  <img ng-if=\"!$ctrl.tweet.video_url\" ng-src=\"{{::picUrl}}\" img-preload=\"img-preload\" zoom-image=\"zoom-image\" data-img-src=\"{{::picUrl}}\" class=\"fade\"/>\n  <video ng-if=\"$ctrl.tweet.video_url\" poster=\"{{::picUrl}}\" autoplay=\"autoplay\" loop=\"loop\" controls=\"controls\" muted=\"muted\">\n    <source ng-src=\"{{::$ctrl.tweet.video_url | trusted}}\" type=\"video/mp4\">\n    </source>\n  </video>\n</div>\n<div ng-if=\"!config.isShowOnlyImage\" class=\"timeline__post__text__container\">\n  <div ng-if=\"!$ctrl.tweet.retweeted_status\" ng-bind-html=\"$ctrl.tweet.text | newlines\" class=\"timeline__post--text\">\n  </div>\n  <div ng-if=\"$ctrl.tweet.retweeted_status\" class=\"timeline__post--blockquote\">\n    <p><a twitter-id-str=\"{{::$ctrl.tweet.retweeted_status.user.id_str}}\" show-tweet=\"show-tweet\">{{::$ctrl.tweet.retweeted_status.user.screen_name}}\n      </a>\n    </p>\n    <blockquote>\n      <div ng-bind-html=\"$ctrl.tweet.text | newlines\" class=\"timeline__post--text\">\n      </div>\n    </blockquote>\n  </div>\n</div>\n<div class=\"timeline__post--footer\">\n  <div class=\"timeline__post--footer--contents\">\n    <div class=\"timeline__post--footer--contents--controls\">\n      <i retweet-num=\"$ctrl.tweet.retweetNum\" retweeted=\"$ctrl.tweet.retweeted\" tweet-id-str=\"{{::$ctrl.tweet.tweetIdStr}}\" retweetable=\"retweetable\" class=\"fa fa-retweet icon-retweet\">{{$ctrl.tweet.retweetNum}}</i>\n      <i fav-num=\"$ctrl.tweet.favNum\" favorited=\"$ctrl.tweet.favorited\" tweet-id-str=\"{{::$ctrl.tweet.tweetIdStr}}\" favoritable=\"favoritable\" class=\"fa fa-heart icon-heart\">{{$ctrl.tweet.favNum}}</i>\n      <a>\n        <i data-url=\"{{::$ctrl.tweet.extended_entities.media[0].media_url}}:orig\" filename=\"{{::$ctrl.tweet.fileName}}\" download-from-url=\"download-from-url\" class=\"fa fa-download\"></i>\n      </a>\n    </div>\n  </div>\n</div>\n",
    bindToController: {
      tweet: "=",
      listIdStr: "="
    },
    controllerAs: "$ctrl",
    controller: ListLayoutTweet
  };
});

ListLayoutTweet = (function() {
  function ListLayoutTweet() {
    console.log(this);
  }

  return ListLayoutTweet;

})();




