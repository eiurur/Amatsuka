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

  ls = localStorage
  maxId = maxId || 0

  $scope.limitNum = 10

  $scope.listIdStr       = JSON.parse(ls.getItem 'amatsukaList') || {}
  $scope.amatsukaMemberList = JSON.parse(ls.getItem 'amatsukaFollowList') || []


  unless _.isEmpty(TweetService.amatsukaList.data) or _.isEmpty(TweetService.amatsukaList.member)
    console.time 'TweetService.amatsukaList.data.id_str'
    $scope.listIdStr = TweetService.amatsukaList.data.id_str
    console.timeEnd 'TweetService.amatsukaList.data.id_str'
    console.time 'nomarlizeMembers'
    $scope.amatsukaMemberList = TweetService.nomarlizeMembers(TweetService.amatsukaList.member)
    console.timeEnd 'nomarlizeMembers'
    $scope.limitNum = 100000
    return

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

    membersNormalized = TweetService.nomarlizeMembers(data.data.users)
    $scope.amatsukaMemberList = membersNormalized

    # 更新(メンバー)
    TweetService.amatsukaList.member = data.data.users

    console.timeEnd 'getListsMembers'
    $scope.limitNum = 100000