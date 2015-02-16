angular.module "myApp.controllers"
  .controller "IndexCtrl", (
    $scope
    $rootScope
    AuthService
    TweetService
    ListService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user

  ls = localStorage
  $scope.isLoaded = false
  ListService.amatsukaList =
    data: JSON.parse(ls.getItem 'amatsukaList') || {}
    member: JSON.parse(ls.getItem 'amatsukaFollowList') || []

  # 二回目以降のログイン
  if ListService.hasListData()
    $scope.tweets    = new Tweets([])
    do ListService.update
    $scope.listIdStr = ListService.amatsukaList.data.id_str
    $scope.isLoaded  = true
    return

  ListService.update()
  .then (data) ->
    $scope.tweets = new Tweets([])
  .catch (error) ->
    console.log error
    ListService.init()
    .then (data) ->
      $scope.tweets   = new Tweets([])
      $scope.isLoaded = true


  # 新着読み込みが押されたらツイートを新規に読み込む流れだけど
  # 定期的にsince_id以降のツイートを読み込んで、新着があればボタンに○○件の新着がありますって文面を載せといて
  # それが押されたら即反映のほうがユーザビリティ的によい。
  # $scope.$on 'newTweet', (event, args) ->
  #   console.log 'newTweet on ', args

  #   newTweetsOnlyImage = TweetService.filterIncludeImage args
  #   console.table newTweetsOnlyImage

  #   tweetsNomalized = TweetService.nomalizeTweets(newTweetsOnlyImage, amatsukaFollowList)
  #   $scope.tweets.items = _.uniq(_.union($scope.tweets.items, tweetsNomalized), 'id_str')

  $scope.$on 'addMember', (event, args) ->
    console.log 'addMember on ', args
    TweetService.applyFollowStatusChange $scope.tweets.items, args
