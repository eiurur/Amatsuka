# Factories
angular.module "myApp.factories", []
  .factory 'Tweets', ($http, $q, TweetService) ->

    class Tweets
      constructor: (items, maxId, type, user) ->
        @busy  　= false
        @isLast　= false
        @method = null
        @items 　= items
        @maxId 　= maxId
        @type   = type
        if @type is 'user_timeline' then @user = user


      nextPage: ->
        console.log @busy
        console.log @isLast
        return if @busy or @isLast

        if @type is 'user_timeline'
          @method = TweetService.getUserTimeline(twitterIdStr: @user.id_str, maxId: @maxId, count:100)
        else
          @method = TweetService.getListsStatuses(listIdStr: TweetService.amatsukaList.data.id_str, maxId: @maxId, count:100)

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
          console.time '$q.all '
          $q.all itemsNomalized.map (item) =>
            @addTweet(item)
          .then (result) =>
            @busy = false
            console.timeEnd '$q.all '

            # console.log result
            # console.log '@busy ', @busy

      addTweet: (tweet) ->
        [@items][0].push tweet

    Tweets