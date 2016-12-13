angular.module "myApp.controllers"
  .controller "MemberCtrl", (
    $scope
    $location
    AuthService
    ListService
    AmatsukaList
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'
  unless ListService.hasListData() then $location.path '/'

  $scope.list = new AmatsukaList('Amatsuka')

  $scope.$watch 'searchWord.screen_name', (newData, oldData) ->
    return if newData is oldData

    # 入力フォームが空(全メンバーを表示)
    if newData is ''
      $scope.list.members = []
      $scope.list.memberIdx = 0
      for member, idx in $scope.list.amatsukaMemberList
        return if idx > 20
        $scope.list.members.push member
        $scope.list.memberIdx++
      return

    # 名前を入力したとき
    screenNameTolowerCased = newData.toLowerCase()
    $scope.list.members = $scope.list.amatsukaMemberList.filter (element, index, array) ->
      return element.screen_name.toLowerCase().indexOf(screenNameTolowerCased) isnt -1
