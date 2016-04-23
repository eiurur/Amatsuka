# angular.module "myApp.controllers"
#   .controller "MaoCtrl", (
#     $scope
#     $location
#     ListService
#     Mao
#     ) ->

#   # 共通の処理
#   # AmatsukaList や AmatsukaFollowList の生成処理は /index で行うことにした。
#   ListService.amatsukaList =
#     data: JSON.parse(localStorage.getItem 'amatsukaList') || {}
#     member: JSON.parse(localStorage.getItem 'amatsukaFollowList') || []

#   unless ListService.hasListData() then $location.path '/'

#   # TODO: 前日の日付を指定
#   # # todo: 日、週、月で切り替えるようにして
#   # date = moment().add(-1, 'days').format('YYYY-MM-DD')
#   # $scope.tweetList = new Mao(date)