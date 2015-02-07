angular.module "myApp.services"
  .service "TweetService", ($http, $q) ->

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

    isFollow:  (tweet, userList, isRT = true) ->
      !!_.findWhere(userList, 'id_str': @get(tweet, 'tweet.id_str', isRT))

    nomalizeTweets: (tweets, list) ->
      _.each tweets, (tweet) =>
        isRT = _.has tweet, 'retweeted_status'
        if isRT
          tweet.followStatus = @isFollow(tweet, list)
          # console.log tweet.retweeted_status.user.id_str
          # console.log tweet.followStatus
        tweet.text       = @activateLink(tweet.text)
        tweet.time       = @fromNow(@get(tweet, 'tweet.created_at', false))
        tweet.retweetNum = @get(tweet, 'tweet.retweet_count', isRT)
        tweet.favNum     = @get(tweet, 'tweet.favorite_count', isRT)
        tweet.tweetIdStr = @get(tweet, 'tweet.id_str', isRT)
        tweet.sourceUrl  = @get(tweet, 'display_url', isRT)
        tweet.picOrigUrl = @get(tweet, 'media_url:orig', isRT)
        tweet.user.profile_image_url =
          @iconBigger(tweet.user.profile_image_url)

    nomarlizeMembers: (members) ->
      _.each members, (member) =>
        member.followStatus = true
        member.description = @activateLink(member.description)
        member.profile_image_url =
          @iconBigger(member.profile_image_url)

    get: (tweet, key, isRT) ->
      t = if isRT then tweet.retweeted_status else tweet
      switch key
        when 'description' then t.user.description
        when 'display_url'
          t.entities?.media?[0].display_url # TODO: 一枚しか取れない
        when 'entities' then t.entities
        when 'expanded_url'
          t.entities?.media?[0].expanded_url # TODO: 一枚しか取れない
        when 'followers_count' then t.user.followers_count
        when 'friends_count' then t.user.friends_count
        when 'hashtags'
          t.entities?.hashtags # TODO: 一個しか取れない
        when 'media_url'
          t.entities?.media?[0].media_url # TODO: 一枚しか取れない
        when 'media_url:orig'
          t.entities?.media?[0].media_url+':orig' # TODO: 一枚しか取れない
        when 'name' then t.user.name
        when 'profile_banner_url' then t.user.profile_banner_url
        when 'profile_image_url' then t.user.profile_image_url
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
          result = result.substring(0, i) + (parseInt(n[i], 10) - 1).toString() + result.substring(i + 1)
          return result
      result

    fromNow: (time) ->
      moment(time).fromNow(true)

    filterIncludeImage: (tweets) ->
      _.filter tweets, (tweet) ->
        _.has(tweet, 'extended_entities') and
        !_.isEmpty(tweet.extended_entities.media)

    # TwitterAPI動作テスト用
    twitterTest: (user) ->
      return new Promise (resolve, reject) ->
        $http.post('/api/twitterTest', user: user)
          .success (data) ->
            console.log 'twitterTest in service data = ', data
            return resolve data

    # TwitterAPI、投稿動作テスト用
    twitterPostTest: (user) ->
      return new Promise (resolve, reject) ->
        $http.post('/api/twitterPostTest', user: user)
          .success (data) ->
            console.log 'twitterPostTest in service data = ', data
            return resolve data

    ###
    List
    ###
    getListsList: ->
      return $q (resolve, reject) ->
        $http.get('/api/lists/list')
          .success (data) ->
            console.table data.data
            return resolve data

    createLists: (params) ->
      return $q (resolve, reject) ->
        $http.post('/api/lists/create', params)
          .success (data) ->
            return resolve data

    getListsMembers: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/lists/members/#{params.listIdStr}/#{params.count}")
          .success (data) ->
            return resolve data

    getListsStatuses: (params) ->
      return $q (resolve, reject) ->
        $http.get("/api/lists/statuses/#{params.listIdStr}/#{params.maxId}/#{params.count}")
          .success (data) ->
            return resolve data

    createListsMembers: (params) ->
      return $q (resolve, reject) ->
        $http.post("/api/lists/members/create", params)
          .success (data) ->
            return resolve data

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
    FAV
    ###
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
