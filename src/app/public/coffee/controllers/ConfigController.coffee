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

  # ConfigService.config = JSON.parse(localStorage.getItem 'amatsuka.config') || {}
  # if _.isEmpty ConfigService.config
  #   ConfigService.getFromDB()
  #   .then (config) ->
  #     console.log config
  #   .catch (e) ->
  #     console.log e
  #     do ConfigService.init

  ConfigService.getFromDB()
  .then (config) ->
    ConfigService.set config
  .catch (e) ->
    console.log e
    do ConfigService.init
  .finally ->
    $scope.config = ConfigService.config

  $scope.$watch 'config.includeRetweet', (includeRetweet) ->
    do ConfigService.update
    ConfigService.save2DB()
    .then (data) ->
      console.log data
    .catch (error) ->
      console.log error
    return


  # # For ng
  # $scope.$watch 'config', (newVal, oldVal) ->
  #   do ConfigService.update
  #   ConfigService.save2DB()
  #   .then (data) ->
  #     console.log data
  #   .catch (error) ->
  #     console.log error
  #   return
  # , true