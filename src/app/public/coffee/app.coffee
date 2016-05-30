angular.module('myApp', [
  'ngRoute'
  'ngAnimate'
  'ngSanitize'
  'ngTouch'
  'infinite-scroll'
  'wu.masonry'
  'toaster'
  'ngTagsInput'
  'myApp.controllers'
  'myApp.filters'
  'myApp.services'
  'myApp.factories'
  'myApp.directives'
])
.value 'THROTTLE_MILLISECONDS', 300
.config ($routeProvider, $locationProvider) ->
  $routeProvider.
    when '/',
      templateUrl: 'partials/index'
      controller: 'IndexCtrl'
    .when '/member',
      templateUrl: 'partials/member'
      controller: 'MemberCtrl'
    .when '/list',
      templateUrl: 'partials/list'
      controller: 'ListCtrl'
    .when '/find',
      templateUrl: 'partials/find'
      controller: 'FindCtrl'
    .when '/extract/:id?',
      templateUrl: 'partials/extract'
      controller: 'ExtractCtrl'
    .when '/mao',
      templateUrl: 'partials/mao'
    .when '/fav',
      templateUrl: 'partials/fav'
      controller: 'FavCtrl'
    .when '/config',
      templateUrl: 'partials/config'
      controller: 'ConfigCtrl'
    .when '/help',
      templateUrl: 'partials/help'
      controller: 'HelpCtrl'
    .when "/logout",
      redirectTo: "/"
    .when "http://127.0.0.1:4040/auth/twitter/callback",
      redirectTo: "/"
    .otherwise
      redirectTo: '/'
  $locationProvider.html5Mode true
