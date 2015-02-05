# Factories
angular.module "myApp.factories", []
  .factory 'Tweets', ($http, TweetService) ->

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
          console.table data.data
          if _.isEmpty(data.data)
            @isLast = true
            @busy = false
            return

          @maxId = TweetService.decStrNum(_.last(data.data).id_str)
          items = TweetService.filterIncludeImage data.data
          itemsNomalized = TweetService.nomalize(items)
          @items = @items.concat itemsNomalized
          @busy = false

    Tweets