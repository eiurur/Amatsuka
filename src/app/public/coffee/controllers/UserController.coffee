angular.module "myApp.controllers"
  .controller "UserCtrl", (
    $scope
    $rootScope
    AuthService
    TweetService
    ListService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user

  $scope.isOpened = false

  $scope.$on 'userData', (event, args) ->
    return unless $scope.isOpened
    console.log ListService.amatsukaList
    $scope.user = ListService.nomarlizeMember args
    $scope.listIdStr = ListService.amatsukaList.data.id_str

  $scope.$on 'tweetData', (event, args) ->
    return unless $scope.isOpened
    maxId           = TweetService.decStrNum(_.last(args).id_str)
    tweetsOnlyImage = TweetService.filterIncludeImage args
    tweetsNomalized = TweetService.nomalizeTweets(tweetsOnlyImage)
    console.log 'UserCrel tweetsNomalized = ', tweetsNomalized
    $scope.tweets   = new Tweets(tweetsNomalized, maxId, 'user_timeline', $scope.user.id_str)

  $scope.$on 'isOpened', (event, args) ->
    $scope.isOpened = true
    $scope.user = {}
    $scope.tweets = {}

  $scope.$on 'isClosed', (event, args) ->
    $scope.isOpened = false

  $scope.$on 'addMember', (event, args) ->
    return if _.isUndefined $scope.tweets
    # TweetService.applyFollowStatusChange $scope.tweets.items, args
    # $scope.$broadcast 'addMember2Index', args
    console.log 'addMember on', args
    TweetService.applyFollowStatusChange $scope.tweets.items, args
    # _.map $scope.tweets.items, (tweet) ->
    #   isRT = _.has tweet, 'retweeted_status'
    #   id_str = TweetService.get(tweet, 'user.id_str', isRT)
    #   if id_str is args then tweet.followStatus = true

