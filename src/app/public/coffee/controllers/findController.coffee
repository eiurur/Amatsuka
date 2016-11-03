angular.module "myApp.controllers"
  .controller "FindCtrl", (
    $scope
    $location
    AuthService
    ListService
    Pict
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'
  unless ListService.hasListData() then $location.path '/'

  $scope.pictList = new Pict()
  console.log $scope.pictList