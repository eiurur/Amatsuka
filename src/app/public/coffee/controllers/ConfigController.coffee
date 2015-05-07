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

  ConfigService.config = JSON.parse(localStorage.getItem 'amatsuka.config') || {}
  if _.isEmpty ConfigService.config then do ConfigService.init

  $scope.config = ConfigService.config

  $scope.$watch 'config.includeRetweet', (includeRetweet) ->
    do ConfigService.update
    ConfigService.save2DB()
    .then (data) ->
      console.log data
    .catch (error) ->
      console.log error
    return