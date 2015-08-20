angular.module "myApp.controllers"
  .controller "AuthCtrl", (
    $scope
    $location
    AuthService
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'
