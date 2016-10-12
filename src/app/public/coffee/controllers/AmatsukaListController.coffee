angular.module "myApp.controllers"
  .controller "AmatsukaListCtrl", (
    AuthService
    ListService
    # BlackUserList
    # BlackUserListService
    ) ->
  return if _.isEmpty AuthService.user

  # todo: 後で消す
  # 何かの手違いで'amatsukaList'に文字列型のundefinedが格納されてしまい、
  # それをJSON.pasrseするとエラーが出る。それを回避するための処理。
  # 代替方法があればそっちにする。
  amatsukaList = localStorage.getItem('amatsukaList')
  amatsukaList = if amatsukaList is 'undefined' then {} else JSON.parse amatsukaList

  amatsukaFollowList = localStorage.getItem('amatsukaFollowList')
  amatsukaFollowList = if amatsukaFollowList is 'undefined' then [] else JSON.parse amatsukaFollowList

  if _.isEmpty(amatsukaList) then window.localStorage.clear()

  ListService.amatsukaList =
    data: amatsukaList
    member: amatsukaFollowList


  # TODO: 別ファイル化
  # Blockしているときは、Twitter側でリジェクトしているため、アプリ側でrejectする必要はない。
  # blockUserList = localStorage.getItem('amatsuka.blockUserList')
  # blockUserList = if blockUserList is 'undefined' then {} else JSON.parse blockUserList
  # BlackUserListService.block = blockUserList

  # new BlackUserList().setBlockUserList()
