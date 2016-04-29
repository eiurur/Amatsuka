angular.module "myApp.controllers"
  .controller "ConfigCtrl", (
    $scope
    $location
    AuthService
    ConfigService
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'

  ConfigService.getFromDB()
  .then (config) -> ConfigService.set config
  .catch (e) -> do ConfigService.init
  .finally -> $scope.config = ConfigService.config

  $scope.$watch 'config', (newData, oldData) ->

    # この判定がないとConfigページを開くたびに設定がリセットされてしまう。
    return if JSON.stringify(newData) is JSON.stringify(oldData)

    return unless _.isNumber newData.favLowerLimit

    # localStorageのデータを更新
    do ConfigService.update

    # データベースのデータを更新
    ConfigService.save2DB()
    .then (data) ->
      console.log data
    .catch (error) ->
      console.log error
    return
  , true
