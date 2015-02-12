angular.module "myApp.controllers"
  .controller "MemberCtrl", (
    $scope
    $log
    AuthService
    TweetService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user
  console.log 'Member AuthService.user = ', AuthService.user

  $scope.limitNum = 10
  $scope.listIdStr = null
  $scope.amatsukaMemberList = null

  unless _.isEmpty(TweetService.amatsukaList.data) or _.isEmpty(TweetService.amatsukaList.member)
    $scope.listIdStr = TweetService.amatsukaList.data.id_str
    $scope.amatsukaMemberList =
      TweetService.nomarlizeMembers(TweetService.amatsukaList.member)
    $scope.limitNum = 10000
    return


  maxId = maxId || 0
  ls = localStorage
  $scope.listIdStr       = JSON.parse(ls.getItem 'amatsukaList') || {}
  $scope.amatsukaMemberList = JSON.parse(ls.getItem 'amatsukaFollowList') || []

  console.time 'getListsList'

  TweetService.getListsList()
  .then (data) ->

    amatsukaList = _.findWhere data.data, 'name': 'Amatsuka'
    $scope.listIdStr = amatsukaList.id_str
    console.timeEnd 'getListsList'

    # 更新(リストデータ)
    TweetService.amatsukaList.data = amatsukaList

    console.time 'getListsMembers'
    TweetService.getListsMembers(listIdStr: amatsukaList.id_str)

  .then (data) ->

    $scope.amatsukaMemberList = TweetService.nomarlizeMembers(data.data.users)

    # 更新(メンバー)
    TweetService.amatsukaList.member = data.data.users

    console.timeEnd 'getListsMembers'
    $scope.limitNum = 100000