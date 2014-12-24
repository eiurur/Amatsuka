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
        when 'tweet.id_str' then t.id_str
        when 'name' then t.user.name
        when 'media_url'
          t.entities?.media?[0].media_url # TODO: 一枚しか取れない
        when 'user.id_str' then t.user.id_str
        when 'profile_image_url' then t.user.profile_image_url
        when 'screen_name' then t.user.screen_name
        when 'text' then t.text
        else null

