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
        @method
        .then (data) =>
          console.log data
          console.log '@method maxId', @maxId
          if _.isEmpty(data.data)
            @isLast = true
            @busy = false
            return

          @maxId = TweetService.decStrNum(_.last(data.data).id_str)
          itemsImageOnly = TweetService.filterIncludeImage data.data
          itemsNomalized = TweetService.nomalizeTweets(itemsImageOnly, TweetService.amatsukaList.member)
        .then (itemsNomalized) =>
          $q.all itemsNomalized.map (item) =>
            @addTweet(item)
          .then (result) =>
            @busy = false
            # console.log result
            # console.log '@busy ', @busy

      addTweet: (tweet) ->
        [@items][0].push tweet

    Tweets