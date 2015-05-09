# Factories
angular.module "myApp.factories", []
  .factory 'Tweets', ($http, $q, ToasterService, TweetService, ListService) ->

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

      # ###
      # # キャッシュをとっておき、体感速度を向上させる。
      # # 死ぬほど面倒だからどうしよう。
      # ###
      # saveTweet2LocalStorage: ->
      #   switch @type
      #     when 'fav'
      #       ls.setItem 'favTweetList', JSON.stringify(@items)
      #     else
      #       ls.setItem 'amatsukaTweetList', JSON.stringify(@items)


      normalizeTweet: (data) =>
        return new Promise (resolve, reject) =>
          if data.err? then reject data.err
          if _.isEmpty(data.data) then reject statusCode: 10100

          @maxId         = TweetService.decStrNum _.last(data.data).id_str
          itemsImageOnly = TweetService.filterIncludeImage data.data
          itemsNomalized = TweetService.nomalizeTweets itemsImageOnly, ListService.amatsukaList.member
          resolve itemsNomalized

      assignTweet: (tweets) =>
        return new Promise (resolve, reject) =>
          if _.isEmpty tweets then reject statusCode: 100110

          do =>
            $q.all tweets.map (tweet) =>
              [@items][0].push tweet
            .then (result) =>
              @busy = false
            return
          return

      checkError: (statusCode) =>
        console.log statusCode
        switch statusCode
          when 429
            # Rate limit exceeded
            ToasterService.warning title: 'ツイート取得API制限', text: '15分お待ちください'
          when 10100
            # 最後まで読み込み終了
            @isLast = true
            @busy = false
            ToasterService.success title: '全ツイート取得完了', text: '全て読み込みました'
          when 10110
            # 取得するツイートが0
            @busy = false
        return


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

        do =>
          @method
          .then (data) =>
            @normalizeTweet data
          .then (itemsNomalized) =>
            @assignTweet itemsNomalized
          .catch (error) =>
            @checkError error.statusCode
          return

    Tweets

  .factory 'List', (TweetService, ListService) ->
    class List
      constructor: (name, idStr) ->
        @name  　= name
        @idStr  　= idStr
        @isLast　= false
        @count  = 20
        @members 　= []
        @memberIdx 　= 0
        @amatsukaListIdStr = ListService.amatsukaList.data.id_str

      loadMember: ->
        TweetService.getListsMembers listIdStr: @idStr, count: 1000
        .then (data) =>
          @members = ListService.nomarlizeMembersForCopy data.data.users

      copyMember2AmatsukaList: ->
        # id_strだけを抜き出す。
        # membersOnlyIdStr = _.pluck @members, 'id_str'
        return if @members.length is 0

        # TODO: 100人ずつしか追加できないから、lengthを100で割った回数分回す。
        twitterIdStr = ''
        _.each @members, (user) -> twitterIdStr += "#{user.id_str},"
        TweetService.createAllListsMembers(listIdStr: @amatsukaListIdStr, twitterIdStr: twitterIdStr)
        .then (data) ->
          console.log 'copyMember2AmatsukaList ok', data

    List

  .factory 'AmatsukaList', (TweetService, ListService) ->

    class AmatsukaList # extends List
      # TODO: AmatsukaList1だけでなく、他のリストにも対応できるよう汎用的な構造にする

      constructor: (name) ->
        @name  　= name
        @isLast　= false
        @count  = 20
        @members 　= []
        @memberIdx 　= 0

        # TODO: 共通の値だからクラス変数にしたい
        @ls = localStorage
        @idStr = JSON.parse(@ls.getItem 'amatsukaList') || {}
        @amatsukaMemberList = ListService.nomarlizeMembers(JSON.parse(@ls.getItem 'amatsukaFollowList')) || []
        @amatsukaMemberLength = @amatsukaMemberList.length
        do @updateAmatsukaList

        # todo: Listごとの要素数に変更。(今は暫定的にAmatsukaListの人数で固定)
        @length = @amatsukaMemberList.length

      updateAmatsukaList: ->
        ListService.update()
        .then (users) =>
          @idstr = ListService.amatsukaList.data.id_str
          @amatsukaMemberList = ListService.nomarlizeMembers(users)
          @length = @amatsukaMemberList.length

      loadMoreMember: ->
        return if @isLast
        @members = @members.concat @amatsukaMemberList[@memberIdx...@memberIdx+@count]
        @memberIdx += @count
        if @memberIdx > @amatsukaMemberLength then @isLast = true
        return

    AmatsukaList