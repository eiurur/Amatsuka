angular.module "myApp.controllers"
  .controller "MemberCtrl", (
    $scope
    $location
    AuthService
    AmatsukaList
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'

  $scope.list = new AmatsukaList('Amatsuka')