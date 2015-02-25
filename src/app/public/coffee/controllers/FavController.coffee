angular.module "myApp.controllers"
  .controller "FavCtrl", (
    $scope
    $location
    AuthService
    TweetService
    ListService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user

  $scope.isLoaded = false

  ls              = localStorage
  ListService.amatsukaList =
    data: JSON.parse(ls.getItem 'amatsukaList') || {}
    member: JSON.parse(ls.getItem 'amatsukaFollowList') || []

  # AmatsukaList や AmatsukaFollowList の生成処理は /index で行うことにした。
  unless ListService.hasListData()
    console.log 'Go /fav to /'
    $location.path '/'

  $scope.tweets =
   new Tweets([], undefined, 'fav', AuthService.user._json.id_str)
  $scope.isLoaded  = true

  $scope.$on 'addMember', (event, args) ->
    console.log 'fav addMember on ', args
    TweetService.applyFollowStatusChange $scope.tweets.items, args
