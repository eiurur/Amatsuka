angular.module('myApp', [
  'ngRoute'
  'ngAnimate'
  'ngSanitize'
  'infinite-scroll'
  'myApp.controllers'
  'myApp.filters'
  'myApp.services'
  'myApp.factories'
  'myApp.directives'
])
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
    .when '/fav',
      templateUrl: 'partials/fav'
      controller: 'FavCtrl'
    .when '/settings',
      templateUrl: 'partials/settings'
      controller: 'SettingsCtrl'
    .when "/logout",
      redirectTo: "/"
    .when "http://127.0.0.1:4040/auth/twitter/callback",
      redirectTo: "/"
    # otherwise redirectTo: '/'
  $locationProvider.html5Mode true
