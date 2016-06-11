angular.module "myApp.controllers"
  .controller "LikeCtrl", (
    $scope
    $location
    AuthService
    ConfigService
    TweetService
    ListService
    Tweets
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'
  unless ListService.hasListData() then $location.path '/'

  $scope.isLoaded = false
  ConfigService.get().then (config) -> $scope.layoutType = if config.isTileLayout then 'tile' else 'grid'

  $scope.tweets    = new Tweets([], undefined, 'like', AuthService.user._json.id_str)
  $scope.listIdStr = ListService.amatsukaList.data.id_str
  $scope.isLoaded  = true

  $scope.$on 'addMember', (event, args) ->
    console.log 'like addMember on ', args
    TweetService.applyFollowStatusChange $scope.tweets.items, args
    return

  $scope.$on 'resize::resize', (event, args) ->
    console.log 'like resize::resize on ', args.layoutType
    $scope.$apply ->
      $scope.layoutType = args.layoutType
      return
    return