angular.module "myApp.controllers"
  .controller "MemberCtrl", (
    $scope
    $location
    AuthService
    ListService
    AmatsukaList
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'
  unless ListService.hasListData() then $location.path '/'

  $scope.list = new AmatsukaList('Amatsuka')

  # Filter
  $scope.$watch 'searchWord.screen_name', (newData, oldData) ->
    return if newData is oldData
    if newData is ''
      $scope.list.members = []
      $scope.list.memberIdx = 0
      for member, idx in $scope.list.amatsukaMemberList
        return if idx > 20
        $scope.list.members.push member
        $scope.list.memberIdx++
      return

    $scope.list.members = $scope.list.amatsukaMemberList.filter (element, index, array) ->
      return element.screen_name.indexOf(newData) isnt -1
