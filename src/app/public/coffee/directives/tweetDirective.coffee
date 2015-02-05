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
  .directive 'followable', (TweetService) ->
    restrict: 'E'
    replace: true
    scope:
      listIdStr: '@'
      twitterIdStr: '@'
      followStatus: '='
    template: '<span class="label label-default timeline__post--header--label">{{content}}</span>'
    link: (scope, element, attrs) ->
      if scope.followStatus is false then scope.content = '+'
      element.on 'mouseover', (e) ->
        console.log 'fff'
        scope.content = 'フォロー'
        scope.$apply()
      element.on 'mouseout', (e) ->
        scope.content = '+'
        scope.$apply()
      element.on 'click', ->
        console.log scope.listIdStr
        console.log scope.twitterIdStr
        if scope.followStatus is false
          TweetService.createListsMembers(listIdStr: scope.listIdStr, twitterIdStr: scope.twitterIdStr)
          .then (data) ->
            element.fadeOut(200)
