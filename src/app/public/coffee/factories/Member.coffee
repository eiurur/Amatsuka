angular.module "myApp.factories"
  .factory 'Member', ($q, toaster, TweetService, ListService) ->

    class Member
      constructor: (name, idStr) ->
        @name              = name
        @idStr             = idStr
        @isLast            = false
        @count             = 20
        @nextCursor        = -1
        @members           = []
        @memberIdx         = 0
        @amatsukaListIdStr = ListService.amatsukaList.data.id_str

      loadMember: ->
        TweetService.getFollowingList twitterIdStr: @idStr, nextCursor: @nextCursor, count: 200
        .then (data) =>
          console.log data
          return if _.isEmpty(data.data.users)

          console.log data.data.next_cursor
          @members = @members.concat ListService.normalizeMembersForCopy data.data.users
          @nextCursor = data.data.next_cursor_str
          return if data.data.next_cursor is 0
          do @loadMember

      copyMember2AmatsukaList: ->
        return $q (resolve, reject) =>
          return reject 'member is nothing' if @members.length is 0

          twitterIdStr = ''
          _.each @members, (user) -> twitterIdStr += "#{user.id_str},"
          TweetService.createAllListsMembers(listIdStr: @amatsukaListIdStr, twitterIdStr: twitterIdStr)
          .then (data) ->
            console.log 'copyMember2AmatsukaList ok', data
            return resolve data
          .catch (e) ->
            return reject e

    Member
