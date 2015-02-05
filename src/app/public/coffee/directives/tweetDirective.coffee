angular.module "myApp.directives"
  .directive 'favoritable', (TweetService) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      element.on 'click', (event) ->
        TweetService.createFavorite(attrs.tweetIdStr).success((data) ->
          if data.data == null
          else
          return
        ).error (status, data) ->
          console.log status
          console.log data
  .directive 'retweetable', (TweetService) ->
    restrict: 'A'
    scope: num: '='
    link: (scope, element, attrs) ->
      element.on 'click', (event) ->
        if !window.confirm('リツイートしてもよろしいですか？')
          return
        TweetService.statusesRetweet(attrs.tweetIdStr).success (data) ->
          if data.data == null
          else
            console.log data.data.entities.media[0].media_url
