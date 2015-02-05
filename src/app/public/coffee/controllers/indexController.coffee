angular.module "myApp.controllers"
  .controller "IndexCtrl", (
    $scope
    $log
    AuthService
    TweetService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user
  console.log 'Index AuthService.user = ', AuthService.user


  maxId = maxId || 0
  amatsukaList = {}
  amatsukaFollowList = []

  # TweetService.twitterPostTest(AuthService.user)
  # .then (data) ->
  #   $scope.favs = data.data
  #   TweetService.getListsList(AuthService.user)
  # .then (data) ->
  #   $scope.lists = data.data
  #   $scope.$apply()

  console.time 'getListsList'
  TweetService.getListsList()
  .then (data) ->

    amatsukaList = _.findWhere data.data, 'name': 'Amatsuka'
    $scope.listIdStr = amatsukaList.id_str
    console.timeEnd 'getListsList'
    TweetService.getListsMembers(listIdStr: amatsukaList.id_str)

  # .then (data) ->

  #   # 自分をリストに入れちゃったときよう
  #   # 後で消す
  #   TweetService.destroyListsMembers(listIdStr: amatsukaList.id_str, twitterIdStr: '2686409167')

  .then (data) ->

    console.table data.data.users
    amatsukaFollowList = data.data.users
    TweetService.getListsStatuses(listIdStr: amatsukaList.id_str, maxId: maxId, count: 20)

  .then (data) ->

    console.table data.data
    console.time 'newTweets'
    # xxx: new Tweets() だけだと一向に読み込みが始まらない
    # 苦肉の策として、最初のリクエストを明示的に投げて、強制的に起こす手法をとった。
    maxId = TweetService.decStrNum(_.last(data.data).id_str)
    tweets = TweetService.filterIncludeImage data.data
    tweetsNomalized = TweetService.nomalize(tweets, amatsukaFollowList)
    console.table tweetsNomalized
    $scope.tweets = new Tweets(tweetsNomalized, amatsukaList, maxId)
    console.timeEnd 'newTweets'
