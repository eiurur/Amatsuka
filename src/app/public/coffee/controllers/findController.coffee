angular.module "myApp.controllers"
  .controller "FindCtrl", (
    $scope
    $location
    AuthService
    AmatsukaList
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'

  # $scope.list = new AmatsukaList('Amatsuka')