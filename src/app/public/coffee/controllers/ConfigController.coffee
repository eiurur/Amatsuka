angular.module "myApp.controllers"
  .controller "ConfigCtrl", (
    $scope
    AuthService
    TweetService
    ConfigService
    Tweets
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'

  # [WIP]

  ls = localStorage
  ConfigService.config = JSON.parse(ls.getItem 'amatsuka.config') || {}
  if _.isEmpty ConfigService.config then do ConfigService.init

  $scope.config = ConfigService.config
  $scope.$watch 'config.includeRetweet', (includeRetweet) ->
    ConfigService.config.includeRetweet = includeRetweet
    console.log ConfigService
    do ConfigService.update
    return

