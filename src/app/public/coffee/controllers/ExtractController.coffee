angular.module "myApp.controllers"
  .controller "ExtractCtrl", (
    $scope
    $rootScope
    $routeParams
    $timeout
    $location
    Tweets
    AuthService
    TweetService
    ListService
    ConfigService
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'
  unless ListService.hasListData() then $location.path '/'

  $scope.listIdStr      = ListService.amatsukaList.data.id_str
  $scope.layoutType     = 'grid'
  $scope.filter         = screenName: '', keyword: '', isIncludeRetweet: false
  $scope.extract        = {}
  $scope.extract.tweets = []
  $scope.isLoading      = false
  $scope.isUserFound    = false

  ConfigService.get()
  .then (config) ->
    $scope.layoutType = if config.isTileLayout then 'tile' else 'grid'

  filterPic = (params = screenName: $scope.filter.screenName) ->
    $scope.isLoading = true
    $scope.message = "Now fetching. This process will take a long time."

    # screenNameからuserDataを取得(id_strが必要)
    TweetService.showUsers(params)

    # ユーザデータを$scopeに追加
    .then (data) -> $scope.extract.user = ListService.normalizeMember data.data

    # 対象ユーザの画像ツイートを3200件取得(1)
    .then (user) -> TweetService.getAllPict(twitterIdStr: user.id_str, isIncludeRetweet: $scope.filter.isIncludeRetweet)

    # 画像だけのツイートから、対象キーワードを含むツイートだけを抽出(3)
    .then (tweetListContainedImage) ->
      console.log tweetListContainedImage
      _.chain(tweetListContainedImage)
        .filter (tweet) -> ~tweet.text.indexOf($scope.filter.keyword)
        .value()

    # (3)のツイートを形態素解析し、名詞とハッシュタグを抽出(4)

    # (4)の単語集を頻出順にソート(5)

    # (5)の辞書を10件だけに絞る？(6)

    # (6)の辞書を元に、(3)と同じ手順で画像ツイートを抽出(7)

    # (7)のツイートを$scopeに代入
    .then (data) ->
      console.log data
      tweets = TweetService.normalizeTweets data, ListService.amatsukaList.member
      $scope.extract.tweets = tweets.sort (a, b) -> b.totalNum - a.totalNum
      $scope.isLoading = false
      $scope.isUserFound = true
      $timeout ->
        $rootScope.$broadcast('masonry.reload')
      , 4000
    .catch (err) ->
      console.log(err)
      $scope.isLoading = false
      $scope.isUserFound = false
      $scope.message = "#{$scope.filter.screenName} is not found"


  # Extractページを直接開いたとき
  if $routeParams.id is undefined
    console.log 'undefined' # 何もしない
  else # 他のページからid_strまたはscreenNameをもらって遷移したとき
    console.log $scope.filter.keyword
    if $routeParams.id.indexOf '@' is -1
      console.log '@ScreenName'
      params = screenName: $routeParams.id
    else
      console.log 'id_str'
      params = twitterIdStr: $routeParams.id
    filterPic(params)

  $scope.execFilteringPictWithKeyword = ->
    console.log $scope.filter
    filterPic()


  $scope.$on 'addMember', (event, args) ->
    console.log 'index addMember on ', args
    TweetService.applyFollowStatusChange $scope.extract.tweets, args
    return

  $scope.$on 'resize::resize', (event, args) ->
    console.log 'index resize::resize on ', args.layoutType
    $scope.$apply ->
      $scope.layoutType = args.layoutType
      return
    return