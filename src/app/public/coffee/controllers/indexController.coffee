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

  $scope.listIdStr = ''
  $scope.isLoaded  = false

  ls               = localStorage
  ListService.amatsukaList =
    data: JSON.parse(ls.getItem 'amatsukaList') || {}
    member: JSON.parse(ls.getItem 'amatsukaFollowList') || []

  ListService.isReturnSameUser()
  .then (isSame) ->
    if isSame
      console.log '同じ！１'
      $scope.tweets = new Tweets([])
      do ->
        ListService.update()
        .then (data) ->
          console.log 'ok'
        return
      return

    console.log '違う'
    ListService.update()
    .then (data) ->
      console.info '2.1'
      console.log 'nnn data = ', data

      # 別のユーザ再でログイン
      $scope.tweets = new Tweets([])
    .catch (error) ->
      console.info '2.2'
      console.error error

      # ログインユーザはAmatsuka Listを未作成(初ログイン)
      ListService.init()
      .then (data) ->
        console.info '3'
        console.log 'init'
        $scope.tweets = new Tweets([])

  .finally ->
    console.info '10'
    console.log $scope.tweets
    $scope.listIdStr = ListService.amatsukaList.data.id_str
    $scope.isLoaded  = true
    console.log '終わり'


  $scope.$on 'addMember', (event, args) ->
    console.log 'index addMember on ', args
    TweetService.applyFollowStatusChange $scope.tweets.items, args
