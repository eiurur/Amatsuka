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
          tweets = tweets.map (item) => item.tweet = JSON.parse item.tweetStr

          tweetsNormalized = TweetService.normalizeTweets tweets, ListService.amatsukaList.member

          # 同じユーザのツイートを配列にまとめる
          tweetsGroupBy = _(tweetsNormalized).groupBy((o) -> o.user.id_str).value()

          # tweet_id_str: tweet_object の形で返ってくるため、tweet_objectだけを抽出
          pictTweetList = _.values(tweetsGroupBy)

          # tweet_objectからuserデータを取り出してViewに合わせたデータ構造に書き換える
          result = pictTweetList.map (item) -> user: item[0].user, pictTweetList: item

          console.log 'pictTweetList = ', pictTweetList
          result = result.map (item) ->
            # 複数枚イラストをここで平坦化。tweetオブジェクトも含めるのは、media.id_strはmediaのid_strであって、tweetのid_strではなく
            # show_statusesで必要なのはtweetのid_strであるのでここで付与する
            pictList = _.flatten item.pictTweetList.map (tweet) ->
              tweet.extended_entities.media.map (media) ->
                tweet: tweet, media: media
            user: item.user, pictList: pictList

          console.log result
          return resolve result

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
