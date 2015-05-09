angular.module "myApp.controllers"
  .controller "ListCtrl", (
    $scope
    AuthService
    TweetService
    List
    AmatsukaList
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'

  # [WIP]

  $scope.amatsukaList = new AmatsukaList('Amatsuka')

  TweetService.getListsList(AuthService.user._json.id_str)
  .then (data) ->

    # 人のAmatuskaリストをフォローしたとき、そのリストが一覧に表示されないため、full_nameの方を使う。
    # l = _.reject data.data, (list) -> list.name is 'Amatsuka'
    l = _.reject data.data, (list) -> list.full_name is "@#{AuthService.user.username}/amatsuka"
    $scope.ownList = l

  $scope.$watch 'sourceListData', (list) ->
    return unless list?.name?
    console.log list
    do ->
      $scope.sourceList = {}
      $scope.sourceList = new List(list.name, list.id_str)
      $scope.sourceList.loadMember()

      # TODO: $scope.sourceListに {countChecked: 数} を代入する処理

      console.log $scope.sourceList
      return

  # TODO: $scope.sourceListにisCheck(?)を追加していく
