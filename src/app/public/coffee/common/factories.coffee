# Factories
angular.module "myApp.factories", []
  .factory 'Tweets', ($http, $q, ToasterService, TweetService, ListService) ->

    class Tweets
      constructor: (items, maxId = undefined, type, twitterIdStr) ->
        @busy         = false
        @isLast       = false
        @method       = null
        @count        = 50
        @items        = items
        @maxId        = maxId
        @type         = type
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
          if data.error? then reject data.error
          if _.isEmpty(data.data) then reject statusCode: 10100

          @maxId         = TweetService.decStrNum _.last(data.data).id_str
          itemsImageOnly = TweetService.filterIncludeImage data.data
          itemsNomalized = TweetService.nomalizeTweets itemsImageOnly, ListService.amatsukaList.member
          resolve itemsNomalized

      assignTweet: (tweets) =>
        return new Promise (resolve, reject) =>
          if _.isEmpty tweets then reject statusCode: 100110

          do =>
            # @items = @items.concat tweets
            # @busy = false

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

  .factory 'Pict', ($q, toaster, TweetService) ->

    class Pict
      constructor: (name, idStr) ->
        @busy   = false
        @isLast = false
        @limit  = 10
        @skip   = 0
        @items  = []

      load: ->
        return if @busy or @isLast
        @busy = true
        TweetService.getPict
          skip: @skip
          limit: @limit
        .then (data) =>
          @items = @items.concat data
          @skip += @limit
          if data.length is 0 then @isLast = true
          @busy = false

          return

    Pict


  .factory 'Member', ($q, toaster, TweetService, ListService) ->

    class Member
      constructor: (name, idStr) ->
        @name              = name
        @idStr             = idStr
        @isLast            = false
        @count             = 20
        @members           = []
        @memberIdx         = 0
        @amatsukaListIdStr = ListService.amatsukaList.data.id_str

      loadMember: ->
        TweetService.getFollowingList twitterIdStr: @idStr, count: 5000
        .then (data) =>
          console.log data
          @members = ListService.nomarlizeMembersForCopy data.data.users

      copyMember2AmatsukaList: ->
        return $q (resolve, reject) =>
          return reject 'member is nothing' if @members.length is 0

          twitterIdStr = ''
          _.each @members, (user) -> twitterIdStr += "#{user.id_str},"
          TweetService.createAllListsMembers(listIdStr: @amatsukaListIdStr, twitterIdStr: twitterIdStr)
          .then (data) ->
            console.log 'copyMember2AmatsukaList ok', data
            return resolve data
          .catch (e) ->
            return reject e

    Member

  .factory 'List', ($q, toaster, TweetService, ListService, Member) ->

    # TODO: ListクラスをBaseとする設計でAmatsukaListClassを修正。

    class List extends Member
      constructor: (name, idStr) ->
        super(name, idStr)
      loadMember: ->
        TweetService.getListsMembers listIdStr: @idStr, count: 1000
        .then (data) =>
          @members = ListService.nomarlizeMembersForCopy data.data.users

    List

  .factory 'AmatsukaList', (TweetService, ListService) ->

    class AmatsukaList # extends List
      # TODO: AmatsukaList1だけでなく、他のリストにも対応できるよう汎用的な構造にする

      constructor: (name) ->
        @name      = name
        @isLast    = false
        @count     = 20
        @members   = []
        @memberIdx = 0

        # TODO: 共通の値だからクラス変数にしたい
        @idStr                = (JSON.parse(localStorage.getItem 'amatsukaList') || {}).id_str
        @amatsukaMemberList   = ListService.nomarlizeMembers(JSON.parse(localStorage.getItem 'amatsukaFollowList')) || []
        @amatsukaMemberLength = @amatsukaMemberList.length

        # 古いリストデータの可能性があるのでここで更新する
        # do @updateAmatsukaList

      updateAmatsukaList: ->
        ListService.update()
        .then (users) =>
          @idstr                = ListService.amatsukaList.data.id_str
          @amatsukaMemberList   = ListService.nomarlizeMembers(users)
          @amatsukaMemberLength = @amatsukaMemberList.length

          # reset
          @length    = @amatsukaMemberLength
          @isLast = true
          console.log @members
          @members   = _.uniq @members.concat(@amatsukaMemberList), 'id_str'
          console.log @members
          # @memberIdx = 0

      loadMoreMember: ->
        return if @isLast
        @members = @members.concat @amatsukaMemberList[@memberIdx...@memberIdx+@count]
        @memberIdx += @count
        if @memberIdx > @amatsukaMemberLength then @isLast = true
        return



    AmatsukaList