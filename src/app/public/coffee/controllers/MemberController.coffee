angular.module "myApp.controllers"
  .controller "MemberCtrl", (
    $scope
    AuthService
    List
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'

  $scope.list = new List('Amatsuka')