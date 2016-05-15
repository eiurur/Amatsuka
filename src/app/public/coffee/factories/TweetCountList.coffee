angular.module "myApp.factories"
  .factory 'TweetCountList', ($q, $httpParamSerializer, MaoService) ->

    class TweetCountList
      constructor: (@date) ->
        @busy   = false
        @isLast = false
        @limit  = 20
        @skip   = 0
        @maxCount = 1000
        @items  = []
        @isAuthenticatedWithMao = true

      load: ->
        return if @busy or @isLast
        @busy = true

        opts =
          skip: @skip
          limit: @limit
        qs = $httpParamSerializer(opts)

        MaoService.aggregateTweetCount(qs)
        .then (tweetCountist) =>
          console.log 'aggregateTweetCount ==> ', tweetCountist
          if tweetCountist.data.length is 0
            @busy = false
            @isLast = true
            return
          if @items.length is 0
            console.log 'tweetCountist = ', tweetCountist
            @maxCount = tweetCountist.data[0].postCount
          tweetCountist.data.forEach (tweet) => @items.push tweet
          @skip += @limit
          @busy = false
        .catch (err) =>
          @isLast = true
          @busy = false
          @isAuthenticatedWithMao = false

    TweetCountList
