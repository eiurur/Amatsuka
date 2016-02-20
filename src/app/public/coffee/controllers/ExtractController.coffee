angular.module "myApp.controllers"
  .controller "ExtractCtrl", (
    $scope
    $routeParams
    $location
    Tweets
    AuthService
    TweetService
    ListService
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'

  # 共通の処理
  # AmatsukaList や AmatsukaFollowList の生成処理は /index で行うことにした。
  ListService.amatsukaList =
    data: JSON.parse(localStorage.getItem 'amatsukaList') || {}
    member: JSON.parse(localStorage.getItem 'amatsukaFollowList') || []

  unless ListService.hasListData() then $location.path '/'
  $scope.listIdStr = ListService.amatsukaList.data.id_str


  $scope.filter = screenName: '', keyword: '', isIncludeRetweet: false
  $scope.extract = {}
  $scope.extract.tweets = []


  # Extractページを直接開いたとき
  if $routeParams.id is undefined

    # 何もしない
    console.log 'undefined'

  # 他のページからid_strまたはscreenNameをもらって遷移したとき
  else
    console.log $scope.filter.keyword
    if $routeParams.id.indexOf '@' is -1
      console.log '@ScreenName'
      params = screenName: $routeParams.id
    else
      console.log 'id_str'
      params = twitterIdStr: $routeParams.id

    # todo: 下のコードをコピペした。あとでまとめて。
    $scope.isLoading = true
    TweetService.showUsers(params)
    .then (data) -> $scope.extract.user = ListService.normalizeMember data.data
    .then (user) -> TweetService.getAllPict(twitterIdStr: user.id_str, isIncludeRetweet: $scope.filter.isIncludeRetweet)
    .then (tweetListContainedImage) ->
      console.log tweetListContainedImage
      _.chain(tweetListContainedImage)
        .filter (tweet) -> ~tweet.text.indexOf($scope.filter.keyword)
        # .sortBy('id_str')
        .value()
    .then (data) ->
      console.log data
      tweets = TweetService.normalizeTweets data, ListService.amatsukaList.member
      $scope.extract.tweets = tweets.sort (a, b) -> b.totalNum - a.totalNum
      console.log $scope.extract.tweets
      $scope.isLoading = false



  $scope.execFilteringPictWithKeyword = ->
    console.log $scope.filter

    $scope.isLoading = true;

    # screenNameからuserDataを取得(id_strが必要)
    TweetService.showUsers(screenName: $scope.filter.screenName)

    # ユーザデータを$scopeに追加
    .then (data) -> $scope.extract.user = ListService.normalizeMember data.data

    # 対象ユーザの画像ツイートを3200件取得(1)
    .then (user) -> TweetService.getAllPict(twitterIdStr: user.id_str, isIncludeRetweet: $scope.filter.isIncludeRetweet)

    # 画像だけのツイートから、対象キーワードを含むツイートだけを抽出(3)
    .then (tweetListContainedImage) ->
      console.log tweetListContainedImage
      _.chain(tweetListContainedImage)
        .uniq 'id_str'  # FIXME: 重複が発生している。原因の特定に失敗したので応急処置としてuniq関数にを通す
        .filter (tweet) -> ~tweet.text.indexOf($scope.filter.keyword)
        # .sortBy('id_str')
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
      console.log $scope.extract.tweets
      $scope.isLoading = false


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