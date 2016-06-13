angular.module "myApp.factories"
  .factory 'Mao', ($q, $httpParamSerializer, ListService, MaoService, TweetService) ->

    class Mao
      constructor: (@date) ->
        @busy   = false
        @isLast = false
        @limit  = 20
        @skip   = 0
        @items  = []
        @isAuthenticatedWithMao = true

      normalizeTweets: (tweets) =>
        return new Promise (resolve, reject) =>
          tweets = tweets.map (item) => JSON.parse item.tweetStr

          tweetsNormalized = TweetService.normalizeTweets tweets, ListService.amatsukaList.member

          result = tweetsNormalized.map (tweet) ->
            tweet.extended_entities.media.map (media) ->
              tweet: tweet, media: media

          return resolve _.flatten result

      load: ->
        return if @busy or @isLast
        @busy = true

        opts =
          skip: @skip
          limit: @limit
          date: @date
        qs = $httpParamSerializer(opts)

        MaoService.findByMaoTokenAndDate(qs)
        .then (data) => @normalizeTweets data.data
        .then (normalizedTweets) =>
          if normalizedTweets.length is 0
            @busy = false
            @isLast = true
            return
          normalizedTweets.forEach (tweet) => @items.push tweet
          @skip += @limit
          @busy = false
        .catch (err) =>
          @isLast = true
          @busy = false
          @isAuthenticatedWithMao = false
    Mao
