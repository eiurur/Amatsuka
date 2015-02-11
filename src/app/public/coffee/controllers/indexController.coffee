angular.module "myApp.controllers"
  .controller "IndexCtrl", (
    $scope
    $rootScope
    $log
    AuthService
    TweetService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user

  $scope.isLoaded = false

  ls                 = localStorage
  maxId              = maxId || 0
  amatsukaList       = JSON.parse(ls.getItem 'amatsukaList') || {}
  amatsukaFollowList = JSON.parse(ls.getItem 'amatsukaFollowList') || []

  TweetService.amatsukaList =
    data: JSON.parse(ls.getItem 'amatsukaList') || {}
    member: JSON.parse(ls.getItem 'amatsukaFollowList') || []

  console.log 'TweetService.amatsukaList = ', TweetService.amatsukaList

  # これあとで消す？
  $rootScope.amatsukaFollowList = amatsukaFollowList


  unless _.isEmpty(TweetService.amatsukaList.data) or _.isEmpty(TweetService.amatsukaList.member)
    params =
      listIdStr: amatsukaList.id_str
      count: 20
    TweetService.getListsStatuses(params)
    .then (data) ->
      maxId            = TweetService.decStrNum(_.last(data.data).id_str)
      tweetsOnlyImage  = TweetService.filterIncludeImage data.data
      tweetsNomalized  = TweetService.nomalizeTweets(tweetsOnlyImage)
      $scope.listIdStr = amatsukaList.id_str
      $scope.tweets    = new Tweets(tweetsNomalized, maxId)
      $scope.isLoaded  = true

      # AmatsukaListとAmatsukaFollowListを最新に更新する
      TweetService.getListsList()
    .then (data) ->
      amatsukaList = _.findWhere data.data, 'name': 'Amatsuka'
      $scope.listIdStr = amatsukaList.id_str
      ls.setItem 'amatsukaList', JSON.stringify(amatsukaList)
      TweetService.getListsMembers(listIdStr: amatsukaList.id_str)
    .then (data) ->
      amatsukaFollowList = data.data.users
      ls.setItem 'amatsukaFollowList', JSON.stringify(amatsukaFollowList)
    return

  console.time 'getListsList'
  TweetService.getListsList()
  .then (data) ->

    amatsukaList = _.findWhere data.data, 'name': 'Amatsuka'
    $scope.listIdStr = amatsukaList.id_str
    ls.setItem 'amatsukaList', JSON.stringify(amatsukaList)
    console.timeEnd 'getListsList'

    console.time 'getListsMembers'
    TweetService.getListsMembers(listIdStr: amatsukaList.id_str)

  .then (data) ->

    console.table data.data.users
    amatsukaFollowList = data.data.users
    ls.setItem 'amatsukaFollowList', JSON.stringify(amatsukaFollowList)
    console.timeEnd 'getListsMembers'

    TweetService.getListsStatuses(listIdStr: amatsukaList.id_str, maxId: maxId, count: 50)

  .then (data) ->

    console.time 'newTweets'
    # xxx: new Tweets() だけだと一向に読み込みが始まらない
    # 苦肉の策として、最初のリクエストを明示的に投げて、強制的に起こす手法をとった。
    maxId           = TweetService.decStrNum(_.last(data.data).id_str)
    tweetsOnlyImage = TweetService.filterIncludeImage data.data
    tweetsNomalized = TweetService.nomalizeTweets(tweetsOnlyImage, amatsukaFollowList)
    $scope.tweets   = new Tweets(tweetsNomalized, maxId)
    console.timeEnd 'newTweets'
  .catch (error) ->
    console.log error

    # Amatsuka Listが存在しない(ほんとに初ログイン)
    if error.message is "Cannot read property 'id_str' of undefined"
      console.log 'id_str'
      init()

  init = ->
    # Flow:
    # リスト作成 -> リストに自分を格納 -> リストのメンバを取得 ->　リストのツイートを取得
    params = name: 'Amatsuka', mode: 'private'
    TweetService.createLists(params)
    .then (data) ->
      $scope.listIdStr = data.data.id_str
      TweetService.amatsukaList.data = data.data
      ls.setItem 'amatsukaList', JSON.stringify(data.data)
      params = listIdStr: data.data.id_str, twitterIdStr: undefined
      TweetService.createAllListsMembers(params)
    .then (data) ->
      TweetService.getListsMembers(listIdStr: data.data.id_str)
    .then (data) ->
      TweetService.amatsukaList.member = data.data.users
      ls.setItem 'amatsukaFollowList', JSON.stringify(data.data.users)
      params = listIdStr: TweetService.amatsukaList.data.id_str, maxId: maxId, count: 50
      TweetService.getListsStatuses(params)
    .then (data) ->
      maxId           = TweetService.decStrNum(_.last(data.data).id_str)
      tweets          = TweetService.filterIncludeImage data.data
      tweetsNomalized = TweetService.nomalizeTweets(tweets)
      $scope.tweets   = new Tweets(tweetsNomalized, maxId)
      $scope.isLoaded = true



  # 新着読み込みが押されたらツイートを新規に読み込む流れだけど
  # 定期的にsince_id以降のツイートを読み込んで、新着があればボタンに○○件の新着がありますって文面を載せといて
  # それが押されたら即反映のほうがユーザビリティ的によい。
  $scope.$on 'newTweet', (event, args) ->
    console.log 'newTweet on ', args

    newTweetsOnlyImage = TweetService.filterIncludeImage args
    console.table newTweetsOnlyImage

    tweetsNomalized = TweetService.nomalizeTweets(newTweetsOnlyImage, amatsukaFollowList)
    $scope.tweets.items = _.uniq(_.union($scope.tweets.items, tweetsNomalized), 'id_str')

  $scope.$on 'addMember', (event, args) ->
    console.log 'addMember on ', args
    TweetService.applyFollowStatusChange $scope.tweets.items, args
