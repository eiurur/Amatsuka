angular.module "myApp.controllers"
  .controller "FindCtrl", (
    $scope
    $location
    AuthService
    Pict
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'

  $scope.pictList = new Pict()