angular.module "myApp.services"
  .service "TweetService", ($http, $httpParamSerializer, $q, $injector, BlackUserListService, ConfigService, ToasterService, toaster) ->

    activateLink: (t) ->
      t.replace(
        ///
        ((ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)
        (:[0-9]+)?(\/|\/([\w#!:.?+=&amp;%@!&#45;\/]))?)
        ///g
        , "<a href=\"$1\" target=\"_blank\">$1</a>")
      .replace(
        ///
        (^|\s)(@|＠)(\w+)
        ///g
        , "$1<a href=\"http://www.twitter.com/$3\" target=\"_blank\">@$3</a>")
      .replace(
        ///
        (?:^|[^ーー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9&_/>]+)
        [#＃]([ー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9_]*
        [ー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z]+
        [ー゛゜々ヾヽぁ-ヶ一-龠ａ-ｚＡ-Ｚ０-９a-zA-Z0-9_]*)
        ///g
        ,' <a href="http://twitter.com/search?q=%23$1" target="_blank">#$1</a>')

    # replaceIconSizeFromNormalToBigger
    iconBigger:  (url) ->
      return @.replace 'normal', 'bigger' if _.isUndefined url
      url.replace 'normal', 'bigger'

    hasOrigParameter: (tweet) ->
      console.log tweet

    applyFollowStatusChange: (tweets, twitterIdStr) ->
      # do =>
      console.log 'applyFollowStatusChange tweets = ', tweets
      _.map tweets, (tweet) =>
        isRT = _.has tweet, 'retweeted_status'
        id_str = @get(tweet, 'user.id_str', isRT)
        if id_str is twitterIdStr
          tweet.followStatus = true

    normalizeTweets: (tweets) ->
      console.log tweets
      # do =>
      ListService = $injector.get 'ListService'
      _.map tweets, (tweet) =>
        isRT = _.has tweet, 'retweeted_status'
        # @hasOrigParameter tweet
        tweet.isRT                         = isRT
        tweet.followStatus                 = ListService.isFollow(tweet, isRT)
        tweet.text                         = @expandTweetUrl(tweet, isRT)
        # tweet.text                         = @activateLink(@get(tweet, 'text', isRT))
        tweet.time                         = @fromNow(@get(tweet, 'tweet.created_at', false))
        tweet.retweetNum                   = @get(tweet, 'tweet.retweet_count', isRT)
        tweet.favNum                       = @get(tweet, 'tweet.favorite_count', isRT)
        tweet.tweetIdStr                   = @get(tweet, 'tweet.id_str', isRT)
        tweet.sourceUrl                    = @get(tweet, 'display_url', isRT)
        tweet.picUrlList                   = @get(tweet, 'media_url_https:small', isRT)
        tweet.picOrigUrlList               = @get(tweet, 'media_url_https:orig', isRT)
        tweet.video_url                    = @get(tweet, 'video_url', isRT)
        tweet.fileName                     = @get(tweet, 'screen_name', isRT) + '_' + @get(tweet, 'tweet.id_str', isRT)
        tweet.user.profile_image_url_https = @iconBigger(tweet.user.profile_image_url_https)
        tweet

    isRT: (tweet) ->
      _.has tweet, 'retweeted_status'

    get: (tweet, key, isRT) ->
      t = if isRT then tweet.retweeted_status else tweet
      switch key
        when 'description' then t.user.description
        when 'display_url' then t.entities?.media?[0].display_url
        when 'entities' then t.entities
        when 'expanded_url' then t.entities?.media?[0].expanded_url
        when 'followers_count' then t.user.followers_count
        when 'friends_count' then t.user.friends_count
        when 'hashtags'
          t.entities?.hashtags # TODO: 一個しか取れない
        when 'media_url'
          _.map t.extended_entities.media, (media) -> media.media_url
        when 'media_url_https'
          _.map t.extended_entities.media, (media) -> media.media_url_https
        when 'media_url:orig'
          _.map t.extended_entities.media, (media) -> media.media_url+':orig'
        when 'media_url_https:orig'
          _.map t.extended_entities.media, (media) -> media.media_url_https+':orig'
        when 'media_url_https:small'
          _.map t.extended_entities.media, (media) -> media.media_url_https+':small'
        when 'video_url'
          # videoは一件のみ
          t.extended_entities?.media[0]?.video_info?.variants[0].url
        when 'name' then t.user.name
        when 'profile_banner_url' then t.user.profile_banner_url
        when 'profile_image_url' then t.user.profile_image_url
        when 'profile_image_url_https' then t.user.profile_image_url_https
        when 'statuses_count' then t.user.statuses_count
        when 'screen_name' then t.user.screen_name
        when 'source' then t.source
        when 'text' then t.text
        when 'timestamp_ms' then t.timestamp_ms
        when 'tweet.created_at' then t.created_at
        when 'tweet.favorite_count' then t.favorite_count
        when 'tweet.retweet_count' then t.retweet_count
        when 'tweet.id_str' then t.id_str
        when 'tweet.lang' then t.lang
        when 'user.created_at' then t.user.created_at
        when 'user.id_str' then t.user.id_str
        when 'user.favorite_count' then t.favorite_count
        when 'user.retweet_count' then t.retweet_count
        when 'user.lang' then t.user.lang
        when 'user.url' then t.user.url
        when 'user' then t.user
        else null

    expandTweetUrl: (tweet, isRT) ->
      tweet.text = @get(tweet, 'text', isRT)
      expandedUrlListInTweet = @getExpandedURLFromTweet(tweet.entities)
      _.each expandedUrlListInTweet, (urls) =>
        tweet.text = tweet.text.replace(urls.url, urls.expanded_url)
        return
      tweet.text = @activateLink tweet.text
      tweet.text

    getExpandedURLFromTweet: (entities) ->
      if !_.has(entities, 'urls') then return ''
      entities.urls

    # https://t.co -> https://pixiv ~ (url ver)
    getExpandedURLFromURL: (entities) ->
      if !_.has(entities, 'url') then return ''
      entities.url.urls

    # (description ver)
    getExpandedURLFromDescription: (entities) ->
      if !_.has(entities, 'description') then return ''
      if !_.has(entities.description, 'urls') then return ''
      entities.description.urls

    # max_idは自分のIDも含むため、1だけデクリメントしないとダメ。
    # それ用の関数。
    decStrNum: (n) ->
      n = n.toString()
      result = n
      i = n.length - 1
      while i > -1
        if n[i] == '0'
          result = result.substring(0, i) + '9' + result.substring(i + 1)
          i--
        else
          result =
            result.substring(0, i) +
            (parseInt(n[i], 10) - 1).toString() +
            result.substring(i + 1)
          return result
      result

    fromNow: (time) ->
      moment(time).fromNow(true)

    # TODO: filterって名前なのにrejectしてるぞこの関数。リネームしろ。
    filterIncludeImage: (tweets) ->
      _.reject tweets, (tweet) ->
        !_.has(tweet, 'extended_entities') or
        _.isEmpty(tweet.extended_entities.media)

    # Blockしているときは、Twitter側でリジェクトしているため、アプリ側でrejectする必要はない。
    # rejectTweetByBlockUser: (tweets) ->
    #   blockUserList = BlackUserListService.block or (JSON.parse(localStorage.getItem 'amatsuka.blockUserList') || {})
    #   rejecter = blockUserList.map (user) -> user.id_str
    #   console.log 'rejectTweetByBlockUser'
    #   console.log blockUserList.length
    #   console.log rejecter
    #   _.reject tweets, (tweet) =>
    #     console.log tweet.user
    #     console.log @get 'user.id_str', @isRT(tweet)
    #     console.log rejecter.includes @get 'user.id_str', @isRT(tweet)
    #     rejecter.includes @get 'user.id_str', @isRT(tweet)


    collectProfile: (params) ->
      return $q (resolve, reject) ->
        $http.post('/api/collect/profile', params)
          .then (data) ->
            return resolve data
          .catch (data) ->
            return reject data

    getPict: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/collect/#{params.skip}/#{params.limit}")
          .then (response) ->
            return resolve response.data
          .catch (data) ->
            return reject data

    getPopularTweet: (params) ->
      qs = $httpParamSerializer(params)
      return $q (resolve, reject) ->
        $http.get("/api/collect/picts?#{qs}")
          .then (data) ->
            return resolve data
          .catch (data) ->
            return reject data

    getPictCount: ->
      return $q (resolve, reject) ->
        $http.get("/api/collect/count")
          .then (response) ->
            return resolve response.data.count
          .catch (data) ->
            return reject data

    # For extract. 対象ユーザの画像ツイートを限界まで種痘
    getAllPict: (params) ->
      console.log 'getAllPict params = ', params
      return $q (resolve, reject) =>
        userAllPict = []
        maxId = maxId || 0
        assignUserAllPict = =>
          @getUserTimeline(twitterIdStr: params.twitterIdStr, maxId: maxId, count: 200, isIncludeRetweet: params.isIncludeRetweet)
          .then (data) =>

            # API制限くらったら return
            if _.isUndefined(data.data)
              toaster.pop 'error', 'API制限。15分お待ち下さい。'
              return resolve userAllPict

            # 全部読み終えたら(残りがないとき、APIは最後のツイートだけ取得する === 1) return
            if data.data.length is 0
              toaster.pop 'success', '最後まで読み終えました。'
              return resolve userAllPict

            maxId = @decStrNum data.data[data.data.length - 1].id_str

            # 並び順の整合性をとるため、totalNumとcreatedAt(created_atだと文字列を含んでおり、バグるため、id_str)の設定を行う。
            _.each data.data, (tweet) ->
              tweet.totalNum = tweet.retweet_count + tweet.favorite_count
              tweet.tweetIdStr = tweet.id_str
              return

            userAllPict = userAllPict.concat(data.data)
            assignUserAllPict()
        do assignUserAllPict

    checkError: (statusCode) ->
      console.log statusCode
      switch statusCode
        when 429
          # Rate limit exceeded
          ToasterService.warning title: 'API制限', text: '15分お待ちください'
      return


    ###
    # $httpのerrorメソッドは、サーバーがエラーを返したとき(404とか、500)であって、
    # TwitterAPIがAPI制限とかのエラーを返したときはsuccessメソッドの方へ渡されるため、
    # その中でresolve, rejectの分岐を行う
    ###

    getViaAPI: (params = {}) ->
      qs = $httpParamSerializer(params)
      return $q (resolve, reject) ->
        $http.get("/api/twitter?#{qs}")
        .then (data) ->
          return resolve data
        .catch (err) ->
          return reject err


    postViaAPI: (params) ->
      return $q (resolve, reject) ->
        $http.post("/api/twitter", params)
        .then (data) ->
          return resolve data
        .catch (data) ->
          return reject data


    ###
    List
    ###
    getListsList: (params) ->
      return $q (resolve, reject) =>
        $http.get("/api/lists/list/#{params.twitterIdStr}")
          .then (data) =>
            console.log "/api/lists/list/#{params.twitterIdStr}", data
            if _.has data, 'error'
              @checkError data.error.statusCode
              return reject data
            return resolve data
          .catch (data) ->
            return reject data

    createLists: (params) ->
      return $q (resolve, reject) ->
        $http.post('/api/lists/create', params)
          .then (data) ->
            return resolve data
          .catch (data) ->
            return reject data

    getListsMembers: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/lists/members/#{params.listIdStr}/#{params.count}")
          .then (data) ->
            return resolve data
          .catch (data) ->
            return reject data

    getListsStatuses: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/lists/statuses/#{params.listIdStr}/#{params.maxId}/#{params.count}")
          .then (data) ->
            return resolve data
          .catch (data) ->
            return reject data

    createListsMembers: (params) ->
      return $q (resolve, reject) ->
        $http.post("/api/lists/members/create", params)
          .then (data) ->
            return resolve data
          .catch (data) ->
            return reject data

    createAllListsMembers: (params) ->
      return $q (resolve, reject) ->
        $http.post("/api/lists/members/create_all", params)
          .then (data) ->
            return resolve data
          .catch (data) ->
            return reject data

    destroyListsMembers: (params) ->
      return $q (resolve, reject) ->
        $http.post("/api/lists/members/destroy", params)
          .then (data) ->
            return resolve data

    ###
    Timleine
    ###
    getUserTimeline: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/timeline/#{params.twitterIdStr}/#{params.maxId}/#{params.count}?isIncludeRetweet=#{params.isIncludeRetweet}")
          .then (data) ->
            return resolve data
          .catch (data) ->
            return reject data

    ###
    Follow
    ###
    getFollowingList: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/friends/list/#{params.twitterIdStr}/#{params.count}")
          .then (data) ->
            return resolve data

    ###
    Block, Mute
    ###
    mute: (params) ->
      opts = {}
      opts.user_id = params.twitterIdStr
      opts.method = 'mutes'
      opts.type = if params.isMuting then 'users/destroy' else 'users/create'
      return @postViaAPI opts

    block: (params) ->
      opts = {}
      opts.user_id = params.twitterIdStr
      opts.method = 'blocks'
      opts.type = if params.isMuting then 'destroy' else 'create'
      return @postViaAPI opts

    getMuteUserIdList: (params) ->
      opts =
        method: 'mutes'
        type: 'users/ids'
        stringify_ids: true
        twitterIdStr: params.twitterIdStr
      return @getViaAPI opts

    getBlockUserIdList: (params) ->
      opts =
        method: 'blocks'
        type: 'ids'
        stringify_ids: true
        twitterIdStr: params.twitterIdStr
      return @getViaAPI opts

    ###
    User
    ###
    showStatuses: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/statuses/show/#{params.tweetIdStr}")
          .then (data) ->
            return resolve data
    ###
    User
    ###
    showUsers: (params) ->
      # 汎用性は後回し。今はidによるリクエストだけを受け付ける。
      # id = params.twitterIdStr || params.screenName
      return $q (resolve, reject) ->
        $http.get("/api/users/show/#{params.twitterIdStr}/#{params.screenName}")
          .then (data) ->
            return resolve data

    ###
    FAV
    ###
    getFavLists: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/favorites/lists/#{params.twitterIdStr}/#{params.maxId}/#{params.count}")
          .then (data) ->
            return resolve data

    createFav: (params) ->
      return $q (resolve, reject) ->
        $http.post('/api/favorites/create', params)
          .then (data) ->
            return resolve data

    destroyFav: (params) ->
      return $q (resolve, reject) ->
        $http.post('/api/favorites/destroy', params)
          .then (data) ->
            return resolve data

    ###
    RT
    ###
    retweetStatus: (params) ->
      return $q (resolve, reject) ->
        $http.post('/api/statuses/retweet', params)
          .then (data) ->
            return resolve data

    destroyStatus: (params) ->
      return $q (resolve, reject) ->
        $http.post('/api/statuses/destroy', params)
          .then (data) ->
            return resolve data
