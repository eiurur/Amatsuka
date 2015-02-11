angular.module "myApp.controllers"
  .controller "FavCtrl", (
    $scope
    $location
    AuthService
    TweetService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user

  ls              = localStorage
  maxId           = maxId || 0
  $scope.isLoaded = false
  TweetService.amatsukaList =
    data: JSON.parse(ls.getItem 'amatsukaList') || {}
    member: JSON.parse(ls.getItem 'amatsukaFollowList') || []
  console.log 'TweetService.amatsukaList = ', TweetService.amatsukaList

  # AmatsukaList や AmatsukaFollowList の生成処理は /index で行うことにした。
  if _.isEmpty(TweetService.amatsukaList.data) and _.isEmpty(TweetService.amatsukaList.member)
    console.log 'Go /fav to /'
    $location.path '/'

  params =
    twitterIdStr:  AuthService.user._json.id_str
    count: 20
  TweetService.getFavLists(params)
  .then (data) ->
    maxId            = TweetService.decStrNum(_.last(data.data).id_str)
    tweetsOnlyImage  = TweetService.filterIncludeImage data.data
    tweetsNomalized  = TweetService.nomalizeTweets(tweetsOnlyImage)
    $scope.listIdStr = TweetService.amatsukaList.data.id_str
    $scope.tweets    = new Tweets(tweetsNomalized, maxId, 'fav', AuthService.user._json.id_str)
    $scope.isLoaded  = true

  $scope.$on 'addMember', (event, args) ->
    console.log 'addMember on ', args
    TweetService.applyFollowStatusChange $scope.tweets.items, args
