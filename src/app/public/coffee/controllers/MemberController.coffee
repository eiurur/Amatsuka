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

  maxId = maxId || 0
  amatsukaList = {}
  console.time 'getListsList'
  TweetService.getListsList()
  .then (data) ->

    amatsukaList = _.findWhere data.data, 'name': 'Amatsuka'
    $scope.listIdStr = amatsukaList.id_str
    console.timeEnd 'getListsList'

    console.time 'getListsMembers'
    TweetService.getListsMembers(listIdStr: amatsukaList.id_str)

  .then (data) ->

    console.table data.data.users
    membersNormalized = TweetService.nomarlizeMembers(data.data.users)
    $scope.amatsukaMemberList = membersNormalized
    console.timeEnd 'getListsMembers'

  # .then (data) ->

  #   console.time 'newTweets'

  #   # xxx: new Tweets() だけだと一向に読み込みが始まらない
  #   # 苦肉の策として、最初のリクエストを明示的に投げて、強制的に起こす手法をとった。
  #   maxId = TweetService.decStrNum(_.last(data.data).id_str)
  #   tweets = TweetService.filterIncludeImage data.data
  #   console.log amatsukaList
  #   console.log amatsukaFollowList
  #   tweetsNomalized = TweetService.nomalize(tweets, amatsukaFollowList)
  #   $scope.tweets = new Tweets(tweetsNomalized, amatsukaList, maxId)

  #   console.timeEnd 'newTweets'

  # $scope.$on 'newTweet', (event, args) ->
  #   console.log 'newTweet on ', args

  #   newTweets = TweetService.filterIncludeImage args
  #   console.table newTweets

  #   tweetsNomalized = TweetService.nomalize(newTweets, amatsukaFollowList)
  #   $scope.tweets.items = _.uniq(_.union($scope.tweets.items, tweetsNomalized), 'id_str')
