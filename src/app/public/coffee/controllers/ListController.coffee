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
    ToasterService
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'
  unless ListService.hasListData() then $location.path '/'


  # [WIP]
  # TODO: 個別に設置されたフォローボタンを押下されたら、右側のAmatsukaListにも反映。その逆(remove)も実装。
  # TODO: まとめてフォローしたとき、全てのSourceListのフォローボタンのフラグをtrueにする

  $scope.amatsukaList = new AmatsukaList('Amatsuka')

  TweetService.getListsList(AuthService.user._json.id_str)
  .then (data) ->

    # 人のAmatuskaリストをフォローしたとき、そのリストが一覧に表示されないため、full_nameの方を使う。
    l = _.reject data.data, (list) -> list.full_name is "@#{AuthService.user.username}/amatsuka"
    # l = _.reject data.data, (list) -> list.name is "Amatsuka"

    $scope.ownList = l or []

    # TODO: リスト取得APIの制限にすぐ引っかかるのでキャッシュを残す
    # ListService.ownList = $scope.ownList

    myFriendParams =
      name: "friends"
      full_name: "friends"
      id_str: AuthService.user.id_str
      uri: '/following'
    $scope.ownList.push myFriendParams
  .catch (error) ->
    console.log 'listController = ', error
    ToasterService.warning title: 'リストAPI取得制限', text: '15分お待ちください'


  $scope.$watch 'sourceListData', (list) ->
    return unless list?.name?
    console.log list
    do ->
      $scope.sourceList = {}
      $scope.sourceList = if list.name is 'friends' then new Member(list.name, AuthService.user._json.id_str) else new List(list.name, list.id_str)
      $scope.sourceList.loadMember()
      return

  $scope.$on 'list:addMember', (event, args) ->
    console.log 'list:copyMember on', args
    do $scope.amatsukaList.updateAmatsukaList
    return

  $scope.$on 'list:copyMember', (event, args) ->
    console.log 'list:copyMember on', args
    do $scope.amatsukaList.updateAmatsukaList
    # copyMember to AmatsukaListボタンを押下してまとめてフォローしたとき、ボタン全ての表記を変更させる。
    $scope.sourceList.members = ListService.changeFollowStatusAllMembers $scope.sourceList.members, true
    $('.btn-follow').each -> this.innerText = 'フォロー解除'
    return

  $scope.$on 'list:removeMember', (event, args) ->
    console.log 'list:removeMember on', args
    do $scope.amatsukaList.updateAmatsukaList
    return
