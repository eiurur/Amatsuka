angular.module "myApp.services"
  .service "ListService", ($http, $q, AuthService, TweetService) ->

    amatsukaList:
      data: []
      member: {}

    registerMember2LocalStorage: ->
      ls = localStorage
      ls.setItem 'amatsukaFollowList', JSON.stringify(@amatsukaList.member)

    # HACK:
    # member objectをまま引数にしたかったけど
    # 大部分のコードがtwitterIdStrになってるので
    # twitterIdStrを引数とする。
    addMember: (twitterIdStr) ->
      TweetService.showUsers(twitterIdStr: twitterIdStr)
      .then (data) =>
        @amatsukaList.member.push data.data
        do @registerMember2LocalStorage

    removeMember: (twitterIdStr) ->
      @amatsukaList.member =
        _.reject(@amatsukaList.member, 'id_str': twitterIdStr)
      do @registerMember2LocalStorage

    isFollow: (target, isRT = true) ->
      targetIdStr = target.id_str
      if _.has target, 'user'
        targetIdStr = TweetService.get(target, 'user.id_str', isRT)
      !!_.findWhere(@amatsukaList.member, 'id_str': targetIdStr)

    # 今のところ、Member.jadeｄふぇ使う関数なので isFollow を全部　true　にしても構わない
    nomarlizeMembers: (members) ->
      _.each members, (member) ->
        member.followStatus      = true
        member.description       = TweetService.activateLink(member.description)
        member.profile_image_url =
         TweetService.iconBigger(member.profile_image_url)

    nomarlizeMember: (member) ->
      member.followStatus      = @isFollow(member)
      member.description       = TweetService.activateLink(member.description)
      member.profile_image_url =
        TweetService.iconBigger(member.profile_image_url)
      member

    update: ->
      ls = localStorage
      params = twitterIdStr: AuthService.user._json.id_str
      TweetService.getListsList(params)
      .then (data) =>
        @amatsukaList.data = _.findWhere data.data, 'name': 'Amatsuka'
        ls.setItem 'amatsukaList', JSON.stringify(@amatsukaList.data)
        TweetService.getListsMembers(listIdStr: @amatsukaList.data.id_str)
      .then (data) =>
        @amatsukaList.member = data.data.users
        ls.setItem 'amatsukaFollowList', JSON.stringify(@amatsukaList.member)
        data.data.users

    init: ->
      ls = localStorage
      # Flow:
      # リスト作成 -> リストに自分を格納 -> リストのメンバを取得 ->　リストのツイートを取得
      params = name: 'Amatsuka', mode: 'private'
      TweetService.createLists(params)
      .then (data) =>
        @amatsukaList.data = data.data
        ls.setItem 'amatsukaList', JSON.stringify(data.data)
        params = listIdStr: data.data.id_str, twitterIdStr: undefined
        TweetService.createAllListsMembers(params)
      .then (data) ->
        TweetService.getListsMembers(listIdStr: data.data.id_str)
      .then (data) =>
        @amatsukaList.member = data.data.users
        ls.setItem 'amatsukaFollowList', JSON.stringify(data.data.users)
        data.data.users

    isReturnSameUser: ->
      ls = localStorage
      params = twitterIdStr: AuthService.user._json.id_str
      TweetService.getListsList(params)
      .then (data) ->
        oldList = JSON.parse(ls.getItem 'amatsukaList') || {}
        newList = _.findWhere(data.data, 'name': 'Amatsuka') || id_str: null
        oldList.id_str is newList.id_str

    hasListData: ->
      !(_.isEmpty(@amatsukaList.data) and _.isEmpty(@amatsukaList.member))
