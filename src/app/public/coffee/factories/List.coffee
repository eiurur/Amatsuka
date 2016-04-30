angular.module "myApp.factories"
  .factory 'List', ($q, toaster, TweetService, ListService, Member) ->

    # TODO: ListクラスをBaseとする設計でAmatsukaListClassを修正。

    class List extends Member
      constructor: (name, idStr) ->
        super(name, idStr)
      loadMember: ->
        TweetService.getListsMembers listIdStr: @idStr, count: 1000
        .then (data) =>
          @members = ListService.normalizeMembersForCopy data.data.users

    List
