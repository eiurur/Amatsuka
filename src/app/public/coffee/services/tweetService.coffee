angular.module "myApp.services"
  .service "TweetService", ($http) ->

    textLinkReplace: () ->
      @.replace(
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

    # まだ動かない
    getHomeTimeline: (type, twitterIdStr) ->
      return new Promise (resolve, reject) ->
        $http.get("/api/timeline/:#{type}/#{twitterIdStr}")
          .success (data) ->
            return resolve data.data

    # まだ動かない
    getUserTimeline: (type, twitterIdStr) ->
      return new Promise (resolve, reject) ->
        $http.get("/api/timeline/:#{type}/#{twitterIdStr}")
          .success (data) ->
            return resolve data.data

    # TwitterAPI動作テスト用
    twitterTest: (user) ->
      return new Promise (resolve, reject) ->
        $http.post('/api/twitterTest', user: user)
          .success (data) ->
            console.log 'twitterTest in service data = ', data
            return resolve data