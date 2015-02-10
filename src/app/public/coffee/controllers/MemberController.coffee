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

  # amatsukaList       = JSON.parse(ls.getItem 'amatsukaList') || {}
  # amatsukaFollowList = JSON.parse(ls.getItem 'amatsukaFollowList') || []

  unless _.isEmpty(TweetService.amatsukaList.data) and _.isEmpty(TweetService.amatsukaList.member)
    $scope.listIdStr = TweetService.amatsukaList.data.id_str
    $scope.amatsukaMemberList = TweetService.nomarlizeMembers(TweetService.amatsukaList.member)
    return

  console.time 'getListsList'

  TweetService.getListsList()
  .then (data) ->

    amatsukaList = _.findWhere data.data, 'name': 'Amatsuka'
    $scope.listIdStr = amatsukaList.id_str
    console.timeEnd 'getListsList'

    # 更新
    TweetService.amatsukaList.data = amatsukaList

    console.time 'getListsMembers'
    TweetService.getListsMembers(listIdStr: amatsukaList.id_str)

  .then (data) ->

    console.table data.data.users
    membersNormalized = TweetService.nomarlizeMembers(data.data.users)
    $scope.amatsukaMemberList = membersNormalized

    # 更新
    TweetService.amatsukaList.data = amatsukaList

    console.timeEnd 'getListsMembers'