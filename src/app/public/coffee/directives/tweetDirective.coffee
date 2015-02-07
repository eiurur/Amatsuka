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
        scope.content = 'フォロー'
        scope.$apply()

      element.on 'mouseout', (e) ->
        scope.content = '+'
        scope.$apply()

      element.on 'click', ->
        console.log scope.listIdStr
        console.log scope.twitterIdStr
        opts =
          listIdStr: scope.listIdStr
          twitterIdStr: scope.twitterIdStr
        if scope.followStatus is false
          element.addClass('label-success')
          element.fadeOut(200)
          TweetService.createListsMembers(opts)
          .then (data) ->
            console.log data

  .directive 'followable', (TweetService) ->
    restrict: 'A'
    scope:
      listIdStr: '@'
      twitterIdStr: '@'
      followStatus: '='
    link: (scope, element, attrs) ->
      element[0].innerText = if scope.followStatus then 'フォロー解除' else 'フォロー'

      element.on 'click', ->
        console.log scope.listIdStr
        console.log scope.twitterIdStr

        opts =
          listIdStr: scope.listIdStr
          twitterIdStr: scope.twitterIdStr

        scope.isProcessing = true
        if scope.followStatus is true
          TweetService.destroyListsMembers(opts)
          .then (data) ->
            element[0].innerText = 'フォロー'
            scope.isProcessing = false

        if scope.followStatus is false
          TweetService.createListsMembers(opts)
          .then (data) ->
            element[0].innerText = 'フォロー解除'
            scope.isProcessing = false

        scope.followStatus = !scope.followStatus

  .directive 'newTweetLoad', ($rootScope, Tweets, TweetService) ->
    restrict: 'E'
    scope:
      listIdStr: '@'
    template: '<a class="btn" ng-disabled="isProcessing">{{text}}</a>'
    link: (scope, element, attrs) ->
      scope.text = '新着を読み込む'
      element.on 'click', ->
        scope.isProcessing = true
        params = listIdStr: scope.listIdStr, count: 50
        TweetService.getListsStatuses(params)
        .then (data) ->
          console.log 'getListsStatuses', data.data
          $rootScope.$broadcast 'newTweet', data.data
          scope.text = '新着を読み込む'
          scope.isProcessing = false
