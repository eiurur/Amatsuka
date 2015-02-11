# Factories
angular.module "myApp.factories", []
  .factory 'Tweets', ($http, $q, TweetService) ->

    class Tweets
      constructor: (items, maxId, type, twitterIdStr) ->
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
        return if @busy or @isLast

        if @type is 'user_timeline'
          @method = TweetService.getUserTimeline(twitterIdStr: @twitterIdStr, maxId: @maxId, count: @count)
        else if @type is 'fav'
          @method = TweetService.getFavLists(twitterIdStr: @twitterIdStr, maxId: @maxId, count: @count)
        else
          @method = TweetService.getListsStatuses(listIdStr: TweetService.amatsukaList.data.id_str, maxId: @maxId, count: @count)

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
          console.time 'decStrNum'
          @maxId = TweetService.decStrNum(_.last(data.data).id_str)
          console.timeEnd 'decStrNum'
          console.time 'filterIncludeImage'
          itemsImageOnly = TweetService.filterIncludeImage data.data
          console.timeEnd 'filterIncludeImage'
          console.time 'nomalizeTweets'
          itemsNomalized = TweetService.nomalizeTweets(itemsImageOnly, TweetService.amatsukaList.member)
          console.timeEnd 'nomalizeTweets'
          itemsNomalized
        .then (itemsNomalized) =>
          do =>
            console.time '$q.all '
            $q.all itemsNomalized.map (item) =>
              @addTweet(item)
            .then (result) =>
              @busy = false
              console.timeEnd '$q.all '

    Tweets