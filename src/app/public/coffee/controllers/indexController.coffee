angular.module "myApp.controllers"
  .controller "IndexCtrl", (
    $scope
    $log
    AuthService
    TweetService
    ) ->
  return if _.isEmpty AuthService.user
