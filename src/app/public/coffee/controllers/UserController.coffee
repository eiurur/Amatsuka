angular.module "myApp.controllers"
  .controller "UserCtrl", (
    $scope
    $rootScope
    $location
    AuthService
    ConfigService
    TweetService
    ListService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user

  #
  # history = 0


  $scope.isOpened = false
  $scope.config = {}

  $scope.$on 'userData', (event, args) ->
    return unless $scope.isOpened
    $scope.user      = ListService.normalizeMember args
    $scope.listIdStr = ListService.amatsukaList.data.id_str
    # ListService.history[history].user = ListService.normalizeMember args
    # ListService.history[history].listIdStr = ListService.amatsukaList.data.id_str
    return

  $scope.$on 'tweetData', (event, args) ->
    return unless $scope.isOpened

    # HACK: ゴリ押し。コピペ。
    ConfigService.getFromDB().then (data) -> $scope.config = data

    # _.last(args)? is 画像ツイートが0
    maxId            = if _.last(args)? then TweetService.decStrNum(_.last(args).id_str) else 0
    tweetsNormalized = TweetService.normalizeTweets(args)
    $scope.tweets    = new Tweets(tweetsNormalized, maxId, 'user_timeline', $scope.user.id_str)

    # ここ要確認
    # TweetService.history[history] = $scope.tweets
    return

  $scope.$on 'isOpened', (event, args) ->
    $scope.isOpened = true
    $scope.user     = {}
    $scope.tweets   = {}
    return
    # history += 1

  $scope.$on 'isClosed', (event, args) ->
    $scope.isOpened = false
    $scope.user     = null
    $scope.tweets   = null
    return
    # history = 0

  # $scope.$on 'pop', (event, args) ->
  #   history -= 1

  $scope.$on 'addMember', (event, args) ->
    return if _.isUndefined $scope.tweets
    console.log 'user addMember on', args
    TweetService.applyFollowStatusChange $scope.tweets.items, args
    return

