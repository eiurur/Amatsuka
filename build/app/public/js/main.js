angular.module('myApp', ['ngRoute', 'ngAnimate', 'ngSanitize', 'myApp.controllers', 'myApp.filters', 'myApp.services', 'myApp.directives']).constant('utils', {
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
  }).when("/logout", {
    redirectTo: "/"
  }).when("http://127.0.0.1:4321/auth/twitter/callback", {
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

angular.module("myApp.controllers").controller("IndexCtrl", ["$scope", "$log", "AuthService", "TweetService", function($scope, $log, AuthService, TweetService) {
  if (_.isEmpty(AuthService.user)) {

  }
}]);

angular.module("myApp.directives").directive("appVersion", ["version", function(version) {
  return function(scope, elm, attrs) {
    elm.text(version);
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

angular.module("myApp.services").service("TweetService", ["$http", function($http) {
  return {
    textLinkReplace: function() {
      return this.replace(/((ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&amp;%@!&#45;\/]))?)/g, "<a href=\"$1\" target=\"_blank\">$1</a>").replace(/(^|\s)(@|＠)(\w+)/g, "$1<a href=\"http://www.twitter.com/$3\" target=\"_blank\">@$3</a>").replace(/(?:^|[^ーー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9&_\/>]+)[#＃]([ー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9_]*[ー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z]+[ー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9_]*)/g, ' <a href="http://twitter.com/search?q=%23$1" target="_blank">#$1</a>');
    },
    iconBigger: function(url) {
      if (_.isUndefined(url)) {
        return this.replace('normal', 'bigger');
      }
      return url.replace('normal', 'bigger');
    },
    get: function(tweet, key, isRT) {
      var t, _ref, _ref1;
      t = isRT ? tweet.retweeted_status : tweet;
      switch (key) {
        case 'tweet.id_str':
          return t.id_str;
        case 'name':
          return t.user.name;
        case 'media_url':
          return (_ref = t.entities) != null ? (_ref1 = _ref.media) != null ? _ref1[0].media_url : void 0 : void 0;
        case 'user.id_str':
          return t.user.id_str;
        case 'profile_image_url':
          return t.user.profile_image_url;
        case 'screen_name':
          return t.user.screen_name;
        case 'text':
          return t.text;
        default:
          return null;
      }
    }
  };
}]);
