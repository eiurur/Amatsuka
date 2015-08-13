angular.module "myApp.services"
  .service "TweetService", ($http, $q, $injector, ConfigService, ToasterService, toaster) ->

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

    nomalizeTweets: (tweets) ->
      console.log tweets
      # do =>
      ListService = $injector.get 'ListService'
      _.each tweets, (tweet) =>
        isRT = _.has tweet, 'retweeted_status'
        # @hasOrigParameter tweet
        tweet.isRT                         = isRT
        tweet.followStatus                 = ListService.isFollow(tweet, isRT)
        tweet.text                         = @activateLink(@get(tweet, 'text', isRT))
        tweet.time                         = @fromNow(@get(tweet, 'tweet.created_at', false))
        tweet.retweetNum                   = @get(tweet, 'tweet.retweet_count', isRT)
        tweet.favNum                       = @get(tweet, 'tweet.favorite_count', isRT)
        tweet.tweetIdStr                   = @get(tweet, 'tweet.id_str', isRT)
        tweet.sourceUrl                    = @get(tweet, 'display_url', isRT)
        tweet.picUrlList                   = @get(tweet, 'media_url_https', isRT)
        tweet.picOrigUrlList               = @get(tweet, 'media_url_https:orig', isRT)
        tweet.video_url                    = @get(tweet, 'video_url', isRT)
        tweet.fileName                     = @get(tweet, 'screen_name', isRT) + '_' + @get(tweet, 'tweet.id_str', isRT)
        tweet.user.profile_image_url_https = @iconBigger(tweet.user.profile_image_url_https)
        return

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
        else null

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

    filterIncludeImage: (tweets) ->
      _.reject tweets, (tweet) ->
        !_.has(tweet, 'extended_entities') or
        _.isEmpty(tweet.extended_entities.media)

    collect: (params) ->
      return $q (resolve, reject) ->
        $http.post('/api/collect', params)
          .success (data) ->
            return resolve data
          .error (data) ->
            return reject data

    getPict: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/collect/#{params.skip}/#{params.limit}")
          .success (data) ->
            return resolve data
          .error (data) ->
            return reject data

    # For extract. 対象ユーザの画像ツイートを限界まで種痘
    getAllPict: (params) ->
      return $q (resolve, reject) =>
        userAllPict = []
        maxId = maxId || 0
        assignUserAllPict = =>
          @getUserTimeline(twitterIdStr: params.twitterIdStr, maxId: maxId, count: 200)
          .then (data) ->

            # API制限くらったら return
            if _.isUndefined(data.data)
              toaster.pop 'error', 'API制限。15分お待ち下さい。'
              return resolve userAllPict

            # 全部読み終えたら(残りがないとき、APIは最後のツイートだけ取得する === 1) return
            if data.data.length < 2
              toaster.pop 'success', '最後まで読み終えました。'
              return resolve userAllPict

            maxId = data.data[data.data.length - 1].id_str
            # 画像付きツイートだけを抽出
            tweetListIncludePict = _.filter(data.data, (tweet) ->
              hasPict = _.has(tweet, 'extended_entities') and !_.isEmpty(tweet.extended_entities.media)
              hasPict
            )
            # 並び順の整合性をとるため、totalNumとcreatedAt(created_atだと文字列を含んでおり、バグるため、id_str)の設定を行う。
            _.each tweetListIncludePict, (tweet) ->
              tweet.totalNum = tweet.retweet_count + tweet.favorite_count
              tweet.tweetIdStr = tweet.id_str
              return

            userAllPict = userAllPict.concat(tweetListIncludePict)
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

    ###
    List
    ###
    getListsList: (params) ->
      return $q (resolve, reject) =>
        $http.get("/api/lists/list/#{params.twitterIdStr}")
          .success (data) =>
            console.log data
            if _.has data, 'error'
              @checkError data.error.statusCode
              return reject data
            return resolve data
          .error (data) ->
            return reject data

    createLists: (params) ->
      return $q (resolve, reject) ->
        $http.post('/api/lists/create', params)
          .success (data) ->
            return resolve data
          .error (data) ->
            return reject data

    getListsMembers: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/lists/members/#{params.listIdStr}/#{params.count}")
          .success (data) ->
            return resolve data
          .error (data) ->
            return reject data

    getListsStatuses: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/lists/statuses/#{params.listIdStr}/#{params.maxId}/#{params.count}")
          .success (data) ->
            return resolve data
          .error (data) ->
            return reject data

    createListsMembers: (params) ->
      return $q (resolve, reject) ->
        $http.post("/api/lists/members/create", params)
          .success (data) ->
            return resolve data
          .error (data) ->
            return reject data

    createAllListsMembers: (params) ->
      return $q (resolve, reject) ->
        $http.post("/api/lists/members/create_all", params)
          .success (data) ->
            return resolve data
          .error (data) ->
            return reject data

    destroyListsMembers: (params) ->
      return $q (resolve, reject) ->
        $http.post("/api/lists/members/destroy", params)
          .success (data) ->
            return resolve data

    ###
    Timleine
    ###
    getUserTimeline: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/timeline/#{params.twitterIdStr}/#{params.maxId}/#{params.count}")
          .success (data) ->
            return resolve data

    ###
    User
    ###
    showStatuses: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/statuses/show/#{params.tweetIdStr}")
          .success (data) ->
            return resolve data
    ###
    User
    ###
    showUsers: (params) ->
      # 汎用性は後回し。今はidによるリクエストだけを受け付ける。
      # id = params.twitterIdStr || params.screenName
      return $q (resolve, reject) ->
        $http.get("/api/users/show/#{params.twitterIdStr}/#{params.screenName}")
          .success (data) ->
            return resolve data

    ###
    FAV
    ###
    getFavLists: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/favorites/lists/#{params.twitterIdStr}/#{params.maxId}/#{params.count}")
          .success (data) ->
            return resolve data

    createFav: (params) ->
      return $q (resolve, reject) ->
        $http.post('/api/favorites/create', params)
          .success (data) ->
            return resolve data

    destroyFav: (params) ->
      return $q (resolve, reject) ->
        $http.post('/api/favorites/destroy', params)
          .success (data) ->
            return resolve data

    ###
    RT
    ###
    retweetStatus: (params) ->
      return $q (resolve, reject) ->
        $http.post('/api/statuses/retweet', params)
          .success (data) ->
            return resolve data

    destroyStatus: (params) ->
      return $q (resolve, reject) ->
        $http.post('/api/statuses/destroy', params)
          .success (data) ->
            return resolve data
