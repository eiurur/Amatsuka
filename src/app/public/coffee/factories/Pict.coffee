angular.module "myApp.factories"
  .factory 'Pict', ($q, toaster, TweetService) ->

    class Pict
      constructor: (name, idStr) ->
        @busy   = false
        @isLast = false
        @limit  = 10
        @skip   = 0
        @items  = []
        @numIllustorator = 0
        @numMaxSkip = 0 # スキップを行う最大回数 48なら5回、50なら5回、59回なら6回
        @doneSkip = [] #


      randomAccess: ->
        console.log @items
        loop
          skip = _.sample _.range(@numMaxSkip)
          break if !@doneSkip.includes(skip) or @doneSkip.length >= @numMaxSkip

        @doneSkip.push skip
        @skip = skip * @limit

        TweetService.getPict
          skip: @skip
          limit: @limit
        .then (data) =>
          @items = @items.concat data
          @skip += @limit
          if @doneSkip.length >= @numMaxSkip then @isLast = true
          @busy = false
        return

      load: ->
        return if @busy or @isLast
        @busy = true

        unless @numIllustorator is 0
          do @randomAccess
          return

        # 最初はデータベースに保存済みのイラストレータの件数を求めてループ回数を決める。
        TweetService.getPictCount()
        .then (count) =>
          console.log  'count', count
          @numIllustorator = count
          @numMaxSkip = (@numIllustorator - 1) / @limit
          do @randomAccess

    Pict
