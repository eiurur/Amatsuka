angular.module "myApp.controllers"
  .controller "DrawerCtrl", (
    $scope
    $location
    ConfigService
    TweetService
    ListService
    Tweets
    ) ->

  $scope.isOpened = false
  $scope.config = {}

  $scope.$on 'showDrawer::userData', (event, args) ->
    return unless $scope.isOpened
    console.log args
    $scope.user      = ListService.normalizeMember args
    $scope.listIdStr = ListService.amatsukaList.data.id_str
    return

  $scope.$on 'showDrawer::tweetData', (event, args) ->
    return unless $scope.isOpened

    # HACK: ゴリ押し。コピペ。
    ConfigService.getFromDB().then (data) ->
      $scope.config = data

      # _.last(args)? is 画像ツイートが0
      maxId            = if _.last(args)? then TweetService.decStrNum(_.last(args).id_str) else 0
      tweetsNormalized = TweetService.normalizeTweets(args)
      $scope.tweets    = new Tweets(tweetsNormalized, maxId, 'user_timeline', $scope.user.id_str)
      $scope.tweets.nextPage()
    return


  $scope.$on 'showDrawer::isOpened', (event, args) ->
    $scope.isOpened = true
    $scope.user     = {}
    $scope.tweets   = {}
    return

  $scope.$on 'showDrawer::isClosed', (event, args) ->
    $scope.isOpened = false
    $scope.user     = {}
    $scope.tweets   = {}
    return

  $scope.$on 'addMember', (event, args) ->
    return if _.isUndefined $scope.tweets
    TweetService.applyFollowStatusChange $scope.tweets.items, args
    return

