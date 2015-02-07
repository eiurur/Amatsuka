# Factories
angular.module "myApp.factories", []
  .factory 'Tweets', ($http, $q, TweetService) ->

    class Tweets
      constructor: (items, list, maxId) ->
        @busy  　= false
        @isLast　= false
        @items 　= items
        @list  　= list
        @maxId 　= maxId

      nextPage: ->
        console.log @busy
        console.log @isLast
        return if @busy or @isLast
        @busy = true
        TweetService.getListsStatuses(listIdStr: @list.id_str, maxId: @maxId, count:100)
        .then (data) =>
          if _.isEmpty(data.data)
            @isLast = true
            @busy = false
            return

          @maxId = TweetService.decStrNum(_.last(data.data).id_str)
          itemsImageOnly = TweetService.filterIncludeImage data.data
          itemsNomalized = TweetService.nomalizeTweets(itemsImageOnly, @list)
          # @items = @items.concat itemsNomalized
        .then (itemsNomalized) =>

          # concatだとブラウザが固まる上、
          # busy = falseのタイミングが早くて二回分のリクエストを一気に投げて、concatしてるため
          # 倍々で負荷がかかっている。
          # だからallして全部済んでからbusy = falseにしたらうまくいくと思いきやそんなことはなく
          # 今悩み中
          console.log '======> @busy ', @busy
          $q.all itemsNomalized.map (item) =>
            @addTweet(item)
          .then (result) =>
            @busy = false
            console.log result
            console.log '@busy ', @busy

      addTweet: (tweet) ->
        [@items][0].push tweet

    Tweets