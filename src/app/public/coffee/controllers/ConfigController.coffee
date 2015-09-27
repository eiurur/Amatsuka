angular.module "myApp.controllers"
  .controller "ConfigCtrl", (
    $scope
    $location
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
    console.log '$scope.config', $scope.config

  $scope.$watch 'config', (newData, oldData) ->
    if JSON.stringify(newData) is JSON.stringify(oldData) then return
    console.log 'newData', newData
    console.log 'oldData', oldData
    do ConfigService.update
    ConfigService.save2DB()
    .then (data) ->
      console.log data
    .catch (error) ->
      console.log error
    return
  , true


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