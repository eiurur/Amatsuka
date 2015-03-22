angular.module "myApp.controllers"
  .controller "ConfigCtrl", (
    $scope
    AuthService
    TweetService
    ConfigService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user
  # [WIP]

  # $scope.displayFormats = ['list', 'grid']
  # $scope.toggleDisplayFormat = ConfigService.toggleDisplayFormat
