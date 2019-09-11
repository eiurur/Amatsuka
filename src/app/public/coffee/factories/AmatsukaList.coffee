# TODO: ListクラスをBaseとする設計でAmatsukaListClassを修正。
angular.module "myApp.factories"
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
        @amatsukaMemberList   = ListService.normalizeMembers(JSON.parse(localStorage.getItem 'amatsukaFollowList')) || []
        @amatsukaMemberLength = @amatsukaMemberList.length

        # 古いリストデータの可能性があるのでここで更新する
        # do @updateAmatsukaList

      updateAmatsukaList: ->
        ListService.update()
        .then (users) =>
          @idstr                = ListService.amatsukaList.data.id_str
          @amatsukaMemberList   = ListService.normalizeMembers(users)
          @amatsukaMemberLength = @amatsukaMemberList.length

          # reset
          @length  = @amatsukaMemberLength
          @isLast  = true
          # @members = _.uniq @amatsukaMemberList.concat(user), false, 'id_str'
          @members = @amatsukaMemberList
          console.log @members
          # @memberIdx = 0

      loadMoreMember: ->
        return if @isLast
        @members = @members.concat @amatsukaMemberList[@memberIdx...@memberIdx+@count]
        @memberIdx += @count
        if @memberIdx > @amatsukaMemberLength then @isLast = true
        setTimeout((-> lozad().observe()), 100)
        return

      reverse: ->
        @amatsukaMemberList.reverse()
        @memberIdx = 0
        @members = []
        @loadMoreMember()

    AmatsukaList
