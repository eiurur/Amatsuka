angular.module "myApp.controllers"
  .controller "UserCtrl", (
    $scope
    $rootScope
    $location
    AuthService
    TweetService
    ListService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user

  #
  # history = 0


  $scope.isOpened = false

  $scope.$on 'userData', (event, args) ->
    return unless $scope.isOpened
    $scope.user      = ListService.normalizeMember args
    $scope.listIdStr = ListService.amatsukaList.data.id_str
    # ListService.history[history].user = ListService.normalizeMember args
    # ListService.history[history].listIdStr = ListService.amatsukaList.data.id_str
    return

  $scope.$on 'tweetData', (event, args) ->
    return unless $scope.isOpened
    maxId           = TweetService.decStrNum(_.last(args).id_str)
    # tweetsOnlyImage = TweetService.filterIncludeImage args
    tweetsNormalized = TweetService.normalizeTweets(tweetsOnlyImage)
    $scope.tweets   =
      new Tweets(tweetsNormalized, maxId, 'user_timeline', $scope.user.id_str)

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

