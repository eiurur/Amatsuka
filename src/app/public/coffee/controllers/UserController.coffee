angular.module "myApp.controllers"
  .controller "UserCtrl", (
    $scope
    $rootScope
    $log
    AuthService
    TweetService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user


  $scope.$on 'userData', (event, args) ->
    $scope.user = TweetService.nomarlizeMember args
    console.log TweetService.amatsukaList
    $scope.listIdStr = TweetService.amatsukaList.data.id_str

  $scope.$on 'tweetData', (event, args) ->
    console.log 'tweetData on ', args
    maxId           = TweetService.decStrNum(_.last(args).id_str)
    tweetsOnlyImage = TweetService.filterIncludeImage args
    tweetsNomalized = TweetService.nomalizeTweets(tweetsOnlyImage)
    console.log 'UserCrel tweetsNomalized = ', tweetsNomalized

    $scope.tweets   = new Tweets(tweetsNomalized, maxId, 'user_timeline', $scope.user)

  $scope.$on 'isClosed', (event, args) ->
    if args
      # FiXME:
      # userData, tweetDataのリクエストが終わる前に閉じると、初期化に失敗する
      # ng-ifにして、要素ごと抹消するとかどうよ？
      $scope.user = {}
      $scope.tweets = {}
