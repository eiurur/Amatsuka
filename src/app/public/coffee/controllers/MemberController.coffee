angular.module "myApp.controllers"
  .controller "MemberCtrl", (
    $scope
    $location
    AuthService
    ListService
    AmatsukaList
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'


  # 共通の処理
  # AmatsukaList や AmatsukaFollowList の生成処理は /index で行うことにした。
  ListService.amatsukaList =
    data: JSON.parse(localStorage.getItem 'amatsukaList') || {}
    member: JSON.parse(localStorage.getItem 'amatsukaFollowList') || []

  unless ListService.hasListData() then $location.path '/'


  $scope.list = new AmatsukaList('Amatsuka')