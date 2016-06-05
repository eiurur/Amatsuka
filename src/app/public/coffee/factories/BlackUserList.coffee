angular.module "myApp.factories"
  .factory 'BlackUserList', (TweetService, BlackUserListService) ->
    class BlackUserList


      constructor: ->
        @blockUserList = []
        @blockOpts =
          method: 'blocks'
          type: 'list'
          cursor: -1


      setBlockUserList: ->
        TweetService.getViaAPI @blockOpts
        .then (blocklist) =>
          if data.error? then reject data.error
          console.log 'blocklist', blocklist.data
          @blockUserList = @blockUserList.concat blocklist.data.users

          if blocklist.data.users.length is 0
            console.log 'blockliist 全部読み終えた！！！'
            console.log @blockUserList
            localStorage.setItem 'amatsuka.blockUserList', JSON.stringify(@blockUserList)
            BlackUserListService.block = @blockUserList
            return

          @blockOpts.cursor = blocklist.data.next_cursor_str
          @setBlockUserList()
        .catch (err) =>


    BlackUserList
