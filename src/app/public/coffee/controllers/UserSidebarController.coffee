angular.module "myApp.controllers"
  .controller "UserSidebarCtrl", (
    $scope
    $location
    ConfigService
    TweetService
    ListService
    Tweets
    ) ->

  $scope.isOpened = false
  $scope.config = {}

  $scope.$on 'showUserSidebar::show', (event, args) ->
    return unless $scope.isOpened
    $scope.user      = ListService.normalizeMember args
    $scope.listIdStr = ListService.amatsukaList.data.id_str

    # HACK: ゴリ押し。コピペ。
    ConfigService.getFromDB().then (data) -> $scope.config = data
    $scope.tweets    = new Tweets([], undefined, 'user_timeline', args.id_str)
    return

  $scope.$on 'showUserSidebar::isOpened', (event, args) ->
    $scope.isOpened = true
    $scope.user     = {}
    $scope.tweets   = {}
    return

  $scope.$on 'showUserSidebar::isClosed', (event, args) ->
    $scope.isOpened = false
    $scope.user     = null
    $scope.tweets   = null
    return

  $scope.$on 'addMember', (event, args) ->
    return if _.isUndefined $scope.tweets
    TweetService.applyFollowStatusChange $scope.tweets.items, args
    return

