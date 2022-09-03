angular.module "myApp.services"
  .service "ListService", ($http, $q, AuthService, TweetService) ->

    amatsukaList:
      data: []
      member: {}

    registerMember2LocalStorage: ->
      localStorage.setItem 'amatsukaFollowList', JSON.stringify(@amatsukaList.member)
      return

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
      return

    isFollow: (target, isRT = true) ->
      # この一時変数(targetIdStr)がなければtweetのid_strにtweet.user.id_strが上書きされてしまい、
      # createFavやretweetができなくなってしまう。
      targetIdStr = target.id_str
      if _.has target, 'user'
        targetIdStr = TweetService.get(target, 'user.id_str', isRT)
      !!_.findWhere(@amatsukaList.member, 'id_str': targetIdStr)


    # 今のところ、Member.jadeで使う関数なので isFollow を全部　true　にしても構わない
    normalizeMembers: (members) ->
      _.each members, (member) ->
        member.followStatus            = true
        member.description             = TweetService.activateLink(member.description)
        member.profile_image_url_https = TweetService.iconBigger(member.profile_image_url_https)
        return

    changeFollowStatusAllMembers: (members, bool) ->
      _.map members, (member) ->
        member.followStatus = bool
        return member


    ###
    # 短縮URLの復元
    # followStatusの代入
    # Bioに含まれるリンクをハイパーリンク化
    # アイコン画像を大きいものに差し替え
    ###
    normalizeMember: (member) ->

      # TODO: 関数化
      # TODO: urlとdescriptionだけでなく、tweetにも対応
      expandedUrlListInDescription = TweetService.getExpandedURLFromDescription(member.entities)
      expandedUrlListInUrl         = TweetService.getExpandedURLFromURL(member.entities)

      _.each expandedUrlListInDescription, (urls) ->
        member.description = member.description.replace(urls.url, urls.expanded_url)
        return

      _.each expandedUrlListInUrl, (urls) ->
        member.url = member.url.replace(urls.url, urls.expanded_url)
        return

      member.followStatus            = @isFollow(member)
      member.description             = TweetService.activateLink(member.description)
      member.profile_image_url_https = TweetService.iconBigger(member.profile_image_url_https)
      member

    ###
    # 既存のリストからAmatsukaListへコピーするメンバーの属性をあるべき姿に正す(?)
    ###
    normalizeMembersForCopy: (members) ->
      _.each members, (member) =>
        member.followStatus            = @isFollow(member)
        member.isPermissionCopy        = true
        member.profile_image_url_https = TweetService.iconBigger(member.profile_image_url_https)
        return

    update: ->
      TweetService.getListsList
        twitterIdStr: AuthService.user._json.id_str
      .then (data) =>
        console.log 'UPDATE!! ', data.data

        @amatsukaList.data = _.findWhere data.data, 'name': 'Amatsuka'
        # 人のAmatuskaリストをフォローしたとき、そのリストをAmatsukaリストとして扱う場合があるため、full_nameの方を使う。
        # @amatsukaList.data = _.findWhere data.data, 'full_name': "@#{AuthService.user.username}/amatsuka"
        console.log 'update: @amatsukaList.data = ', @amatsukaList.data
        localStorage.setItem 'amatsukaList', JSON.stringify(@amatsukaList.data)
        TweetService.getListsMembers(listIdStr: @amatsukaList.data.id_str)
      .then (data) =>
        console.log 'list members ', data.data.users
        @amatsukaList.member = data.data.users
        localStorage.setItem 'amatsukaFollowList', JSON.stringify(@amatsukaList.member)
        data.data.users

    init: ->
      # Flow:
      # リスト作成 -> リストに自分を格納 -> リストのメンバを取得 ->　リストのツイートを取得
      TweetService.createLists
        name: 'Amatsuka'
        mode: 'private'
      .then (data) =>
        @amatsukaList.data = data.data
        localStorage.setItem 'amatsukaList', JSON.stringify(data.data)
        params = listIdStr: data.data.id_str, twitterIdStr: undefined
        TweetService.createAllListsMembers(params)
      .then (data) ->
        TweetService.getListsMembers(listIdStr: data.data.id_str)
      .then (data) =>
        @amatsukaList.member = data.data.users
        localStorage.setItem 'amatsukaFollowList', JSON.stringify(data.data.users)
        data.data.users

    getAmatsukaList: ->
      return $q (resolve, reject) =>
        console.log 'isSameAmatsukaList AuthService.user._json.id_str = ', AuthService.user._json.id_str
        TweetService.getListsList
          twitterIdStr: AuthService.user._json.id_str
        .then (data) ->
          ownLists = data.data
          console.log 'lists = ', ownLists

          return resolve _.findWhere data.data, 'name': 'Amatsuka' || id_str: null
          # 人のAmatuskaリストをフォローしたとき、そのリストをAmatsukaリストとして扱う場合があるため、full_nameの方を使う。
          # return resolve _.findWhere(ownLists, 'full_name': "@#{AuthService.user.username}/amatsuka") || id_str: null
        .catch (err) ->
          reject err
          
    isSameAmatsukaList: ->
      return $q (resolve, reject) =>
        @getAmatsukaList()
        .then (newList) ->
          oldList = JSON.parse(localStorage.getItem 'amatsukaList') || {}
          return resolve oldList.id_str is newList.id_str
        .catch (error) ->
          console.log 'listService isSameAmatsukaList = ', error
          return reject error

    hasListData: ->
      !(_.isEmpty(@amatsukaList.data) and _.isEmpty(@amatsukaList.member))
