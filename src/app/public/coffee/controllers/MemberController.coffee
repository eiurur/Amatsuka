angular.module "myApp.controllers"
  .controller "MemberCtrl", (
    $scope
    AuthService
    TweetService
    ListService
    ) ->
  return if _.isEmpty AuthService.user

  $scope.limitNum = 10
  $scope.listIdStr = null
  $scope.amatsukaMemberList = null

  if ListService.hasListData()
    $scope.listIdStr = ListService.amatsukaList.data.id_str
    $scope.amatsukaMemberList =
      ListService.nomarlizeMembers(ListService.amatsukaList.member)
    $scope.limitNum = 10000
    return


  ls = localStorage
  $scope.listIdStr       = JSON.parse(ls.getItem 'amatsukaList') || {}
  $scope.amatsukaMemberList = JSON.parse(ls.getItem 'amatsukaFollowList') || []
  ListService.update()
  .then (users) ->
    console.log users
    $scope.listIdStr = ListService.amatsukaList.data.id_str
    $scope.amatsukaMemberList = ListService.nomarlizeMembers(users)
    $scope.limitNum = 100000
