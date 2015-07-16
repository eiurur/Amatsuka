angular.module "myApp.controllers"
  .controller "FavCtrl", (
    $scope
    $location
    AuthService
    TweetService
    ListService
    Tweets
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'

  $scope.isLoaded   = false
  $scope.layoutType = 'grid'

  # 共通の処理
  # AmatsukaList や AmatsukaFollowList の生成処理は /index で行うことにした。
  ListService.amatsukaList =
    data: JSON.parse(localStorage.getItem 'amatsukaList') || {}
    member: JSON.parse(localStorage.getItem 'amatsukaFollowList') || []

  unless ListService.hasListData() then $location.path '/'


  $scope.tweets =
    new Tweets([], undefined, 'fav', AuthService.user._json.id_str)
　 $scope.listIdStr = ListService.amatsukaList.data.id_str
  $scope.isLoaded  = true

  $scope.$on 'addMember', (event, args) ->
    console.log 'fav addMember on ', args
    TweetService.applyFollowStatusChange $scope.tweets.items, args
    return

  $scope.$on 'resize::resize', (event, args) ->
    console.log 'fav resize::resize on ', args.layoutType
    $scope.$apply ->
      $scope.layoutType = args.layoutType
      return
    return