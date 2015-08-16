angular.module "myApp.controllers"
  .controller "ListCtrl", (
    $scope
    $location
    AuthService
    TweetService
    ListService
    List
    Member
    AmatsukaList
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'


  # 共通の処理
  # AmatsukaList や AmatsukaFollowList の生成処理は /index で行うことにした。
  ListService.amatsukaList =
    data: JSON.parse(localStorage.getItem 'amatsukaList') || {}
    member: JSON.parse(localStorage.getItem 'amatsukaFollowList') || []

  unless ListService.hasListData() then $location.path '/'


  # [WIP]
  # TODO: 個別に設置されたフォローボタンを押下されたら、右側のAmatsukaListにも反映。その逆(remove)も実装。
  # TODO: まとめてフォローしたとき、全てのSourceListのフォローボタンのフラグをtrueにする

  $scope.amatsukaList = new AmatsukaList('Amatsuka')

  TweetService.getListsList(AuthService.user._json.id_str)
  .then (data) ->

    # 人のAmatuskaリストをフォローしたとき、そのリストが一覧に表示されないため、full_nameの方を使う。
    l = _.reject data.data, (list) -> list.full_name is "@#{AuthService.user.username}/amatsuka"

    $scope.ownList = l or []

    # TODO: リスト取得APIの制限にすぐ引っかかるのでキャッシュを残す
    # ListService.ownList = $scope.ownList

    myFriendParams =
      name: "friends"
      full_name: "@#{AuthService.user.username}/friends"
      id_str: AuthService.user.id_str
    $scope.ownList.push myFriendParams
  .catch (error) ->
    console.log 'listController = ', error


  $scope.$watch 'sourceListData', (list) ->
    return unless list?.name?
    console.log list
    do ->
      $scope.sourceList = {}
      $scope.sourceList = if list.name is 'friends' then new Member(list.name, list.id_str) else new List(list.name, list.id_str)
      $scope.sourceList.loadMember()
      return

  $scope.$on 'list:copyMember', (event, args) ->
    console.log 'list:copyMember on', args
    do $scope.amatsukaList.updateAmatsukaList
    return
