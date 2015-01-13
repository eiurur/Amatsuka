angular.module "myApp.controllers", []
  .controller 'CommonCtrl', ($location, $log, $rootScope, $scope) ->
    $rootScope.$on '$locationChangeStart', (event, next, current) ->
      $log.info 'location changin to: ' + next
      return