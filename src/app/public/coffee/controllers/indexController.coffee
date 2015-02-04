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
    console.timeEnd 'getListsList'
    TweetService.getListsStatuses(listIdStr: amatsukaList.id_str, maxId: maxId)

  .then (data) ->

    console.time 'newTweets'
    # xxx: new Tweets() だけだと一向に読み込みが始まらない
    # 苦肉の策として、最初のリクエストを明示的に投げて、強制的に起こす手法をとった。
    maxId = TweetService.decStrNum(_.last(data.data).id_str)
    tweets = TweetService.filterIncludeImage data.data
    tweetsNomalized = TweetService.nomalize(tweets)
    $scope.tweets = new Tweets(tweetsNomalized, amatsukaList, maxId)
    console.timeEnd 'newTweets'
