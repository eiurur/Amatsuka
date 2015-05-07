angular.module "myApp.controllers"
  .controller "IndexCtrl", (
    $window
    $scope
    $rootScope
    AuthService
    TweetService
    ListService
    ConfigService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user

  $scope.listIdStr  = ''
  $scope.isLoaded   = false
  $scope.layoutType = 'grid'

  ListService.amatsukaList =
    data: JSON.parse(localStorage.getItem 'amatsukaList') || {}
    member: JSON.parse(localStorage.getItem 'amatsukaFollowList') || []

  ListService.isSameUser()
  .then (isSame) ->
    if isSame
      $scope.tweets = new Tweets([])
      do ->
        ListService.update()
        .then (data) ->
          console.log 'ok'
        return
      return

    ListService.update()
    .then (data) ->

      # 別のユーザで再ログインしたとき
      $scope.tweets = new Tweets([])
      return

    .catch (error) ->

      # ログインしたユーザがAmatsuka Listを未作成(初ログイン)のとき
      ListService.init()
      .then (data) ->

        #設定データを初期化
        do ConfigService.init

        # 初期化した設定データをデータベースに格納
        do ConfigService.save2DB

      .then (data) ->
        $scope.tweets = new Tweets([])
        return
      return
    return

  .finally ->
    console.info '10'
    $scope.listIdStr = ListService.amatsukaList.data.id_str
    $scope.isLoaded  = true
    console.log '終わり'
    return


  $scope.$on 'addMember', (event, args) ->
    console.log 'index addMember on ', args
    TweetService.applyFollowStatusChange $scope.tweets.items, args
    return

  $scope.$on 'resize::resize', (event, args) ->
    console.log 'index resize::resize on ', args.layoutType
    $scope.$apply ->
      $scope.layoutType = args.layoutType
      return
    return