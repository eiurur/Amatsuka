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
  # console.table AuthService.user

  ls                 = localStorage
  maxId              = maxId || 0
  amatsukaList       = JSON.parse(ls.getItem 'amatsukaList') || {}
  amatsukaFollowList = JSON.parse(ls.getItem 'amatsukaFollowList') || []

  TweetService.amatsukaList =
    data: amatsukaList
    member: amatsukaFollowList

  console.log 'TweetService.amatsukaList = ', TweetService.amatsukaList

  # これあとで消す？
  $rootScope.amatsukaFollowList = amatsukaFollowList


  unless _.isEmpty(amatsukaList) or _.isEmpty(amatsukaFollowList)
    params =
      listIdStr: amatsukaList.id_str
      count: 20
    TweetService.getListsStatuses(params)
    .then (data) ->
      maxId            = TweetService.decStrNum(_.last(data.data).id_str)
      tweetsOnlyImage  = TweetService.filterIncludeImage data.data
      tweetsNomalized  = TweetService.nomalizeTweets(tweetsOnlyImage, amatsukaFollowList)
      $scope.listIdStr = amatsukaList.id_str
      $scope.tweets    = new Tweets(tweetsNomalized, maxId)

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

    # Amatsuka Listが存在しない
    if error.message is "Cannot read property 'id_str' of undefined"
      console.log 'id_str'
      init()

  init = ->
    # Flow:
    # リスト作成 -> リストに自分を格納 -> リストのメンバを取得 ->　リストのツイートを取得
    params = name: 'Amatsuka', mode: 'private'
    TweetService.createLists(params)
    .then (data) ->
      amatsukaList =  data.data
      $scope.listIdStr = amatsukaList.id_str
      ls.setItem 'amatsukaList', JSON.stringify(amatsukaList)
      params = listIdStr: amatsukaList.id_str, twitterIdStr: AuthService.user._json.id_str
      TweetService.createListsMembers(params)
    .then (data) ->
      TweetService.getListsMembers(listIdStr: amatsukaList.id_str)
    .then (data) ->
      amatsukaFollowList = data.data.users
      ls.setItem 'amatsukaFollowList', JSON.stringify(amatsukaFollowList)
      params = listIdStr: amatsukaList.id_str, maxId: maxId, count: 50
      TweetService.getListsStatuses(params)
    .then (data) ->
      maxId           = TweetService.decStrNum(_.last(data.data).id_str)
      tweets          = TweetService.filterIncludeImage data.data
      tweetsNomalized = TweetService.nomalizeTweets(tweets, amatsukaFollowList)
      $scope.tweets   = new Tweets(tweetsNomalized, maxId)



  # 新着読み込みが押されたらツイートを新規に読み込む流れだけど
  # 定期的にsince_id以降のツイートを読み込んで、新着があればボタンに○○件の新着がありますって文面を載せといて
  # それが押されたら即反映のほうがユーザビリティ的によい。
  $scope.$on 'newTweet', (event, args) ->
    console.log 'newTweet on ', args

    newTweetsOnlyImage = TweetService.filterIncludeImage args
    console.table newTweetsOnlyImage

    tweetsNomalized = TweetService.nomalizeTweets(newTweetsOnlyImage, amatsukaFollowList)
    $scope.tweets.items = _.uniq(_.union($scope.tweets.items, tweetsNomalized), 'id_str')

  $scope.$on 'addMember2Index', (event, args) ->
    console.log 'addMember2Index on ', args
    TweetService.applyFollowStatusChange $scope.tweets.items, args
