angular.module "myApp.controllers"
  .controller "HelpCtrl", (
    $scope
    AuthService
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'
