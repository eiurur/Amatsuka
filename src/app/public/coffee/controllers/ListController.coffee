angular.module "myApp.controllers"
  .controller "ListCtrl", (
    $scope
    AuthService
    TweetService
    List
    AmatsukaList
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'

  # [WIP]

  $scope.amatsukaList = new AmatsukaList('Amatsuka')

  TweetService.getListsList(AuthService.user._json.id_str)
  .then (data) ->
    l = _.reject data.data, (list) -> list.name is 'Amatsuka'
    $scope.ownList = l

  $scope.$watch 'sourceListData', (list) ->
    return unless list?.name?
    console.log list
    do ->
      $scope.sourceList = {}
      $scope.sourceList = new List(list.name, list.id_str)
      $scope.sourceList.loadMember()
      console.log $scope.sourceList
      return
      # $scope.sourceList.members = data.data
    # do ConfigService.update





