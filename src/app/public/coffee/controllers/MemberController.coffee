angular.module "myApp.controllers"
  .controller "MemberCtrl", (
    $scope
    AuthService
    List
    ) ->
  return if _.isEmpty AuthService.user
  $scope.list = new List('Amatsuka')
