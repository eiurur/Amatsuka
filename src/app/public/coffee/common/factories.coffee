# Factories
angular.module "myApp.factories", []
  .factory 'Tweets', ($http, $q, TweetService, ListService) ->

    class Tweets
      constructor: (items, maxId = undefined, type, twitterIdStr) ->
        @busy  　= false
        @isLast　= false
        @method = null
        @count  = 50
        @items 　= items
        @maxId 　= maxId
        @type   = type
        @twitterIdStr = twitterIdStr || null

      addTweet: (tweet) ->
        [@items][0].push tweet

      nextPage: ->
        console.log @busy
        console.log @isLast
        return if @busy or @isLast

        if @type is 'user_timeline'
          @method = TweetService.getUserTimeline(twitterIdStr: @twitterIdStr, maxId: @maxId, count: @count)
        else if @type is 'fav'
          @method = TweetService.getFavLists(twitterIdStr: @twitterIdStr, maxId: @maxId, count: @count)
        else
          @method = TweetService.getListsStatuses(listIdStr: ListService.amatsukaList.data.id_str, maxId: @maxId, count: @count)

        @busy = true
        console.time 'get'
        @method
        .then (data) =>
          console.timeEnd 'get'
          console.log data
          console.log '@method maxId', @maxId

          if _.isEmpty(data.data)
            @isLast = true
            @busy = false
            return

          @maxId         = TweetService.decStrNum(_.last(data.data).id_str)
          itemsImageOnly = TweetService.filterIncludeImage data.data
          itemsNomalized = TweetService.nomalizeTweets(itemsImageOnly, ListService.amatsukaList.member)
          itemsNomalized
        .then (itemsNomalized) =>
          do =>
            $q.all itemsNomalized.map (item) =>
              @addTweet(item)
            .then (result) =>
              @busy = false
            return
          return

    Tweets