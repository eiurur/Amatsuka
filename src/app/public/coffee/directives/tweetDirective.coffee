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
        if scope.followStatus is false
          scope.content = 'ok ...'
          TweetService.createListsMembers(listIdStr: scope.listIdStr, twitterIdStr: scope.twitterIdStr)
          .then (data) ->
            element.fadeOut(200)

  .directive 'newTweetLoad', ($rootScope, TweetService) ->
    restrict: 'E'
    scope:
      listIdStr: '@'
    template: '<button class="btn btn-primary" ng-disabled="isProcessing">{{text}}</button>'
    link: (scope, element, attrs) ->
      scope.text = '新着を読み込む'
      element.on 'click', ->
        console.log 'newTweetLoad', scope.listIdStr
        scope.text = ''
        console.log element
        element.html """
          <button class="btn btn-primary" ng-disabled="isProcessing">
            <i class="fa fa-spin fa-refresh"></i> 読み込み中
          </button>
        """
        scope.isProcessing = true
        TweetService.getListsStatuses listIdStr: scope.listIdStr, count: 50
        .then (data) ->
          console.log 'getListsStatuses', data.data
          $rootScope.$broadcast 'newTweet', data.data
          scope.text = '新着を読み込む'
          scope.isProcessing = false
