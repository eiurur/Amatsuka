angular.module "myApp.controllers"
  .controller "ListCtrl", (
    $scope
    AuthService
    TweetService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user
  console.log 'List AuthService.user = ', AuthService.user
