angular.module "myApp.directives"
  .directive 'favoritable', (TweetService) ->
    restrict: 'A'
    scope:
      favNum: '='
      favorited: '='
      tweetIdStr: '@'
    link: (scope, element, attrs) ->
      element.addClass('favorited') if scope.favorited

      element.on 'click', (event) ->
        if scope.favorited
          element.removeClass('favorited')
          TweetService.destroyFav(tweetIdStr: scope.tweetIdStr)
            .then (data) ->
              scope.favNum -= 1
        else
          element.addClass('favorited')
          TweetService.createFav(tweetIdStr: scope.tweetIdStr)
            .then (data) ->
              scope.favNum += 1

  .directive 'retweetable', (TweetService) ->
    restrict: 'A'
    scope:
      retweetNum: '='
      retweeted: '='
      tweetIdStr: '@'
    link: (scope, element, attrs) ->
      element.addClass('retweeted') if scope.retweeted

      element.on 'click', (event) ->
        if scope.retweeted
          element.removeClass('retweeted')
          TweetService.destroyStatus(tweetIdStr: scope.tweetIdStr)
            .then (data) ->
              scope.retweetNum -= 1
        else if !window.confirm('リツイートしてもよろしいですか？')
          element.addClass('retweeted')
          TweetService.retweetStatus(tweetIdStr: scope.tweetIdStr)
            .then (data) ->
              scope.retweetNum += 1

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
            TweetService.addMember(scope.twitterIdStr)
            console.log 'createListsMembers(opts) darta', data

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
            TweetService.removeMember(scope.twitterIdStr)
            element[0].innerText = 'フォロー'
            scope.isProcessing = false

        if scope.followStatus is false
          TweetService.createListsMembers(opts)
          .then (data) ->
            TweetService.addMember(scope.twitterIdStr)
            element[0].innerText = 'フォロー解除'
            scope.isProcessing = false

        scope.followStatus = !scope.followStatus

  .directive 'showTweet', ($rootScope, TweetService) ->
    restrict: 'A'
    scope:
      twitterIdStr: '@'
    link: (scope, element, attrs) ->
      element.on 'click', ->
        domUserSidebar = angular.element(document).find('.user-sidebar')
        # user-sidebarが開かれた状態で呼び出し。
        # TODO
        # if domUserSidebar.has .user-sidebar-in
        #   shousers -> getUserTimeline -> broadcast
        #   return
        #

        # 初回
        domUserSidebar.addClass('user-sidebar-in')

        body = angular.element(document).find('body')
        body.addClass('scrollbar-y-hidden')
        layer = angular.element(document).find('.layer')
        layer.addClass('fullscreen-overlay')


        layer.on 'click', ->
          body.removeClass('scrollbar-y-hidden')
          layer.removeClass('fullscreen-overlay')
          domUserSidebar.removeClass('user-sidebar-in')
          $rootScope.$broadcast 'isClosed', true

        console.log scope.twitterIdStr
        TweetService.showUsers(twitterIdStr: scope.twitterIdStr)
        .then (data) ->
          console.log data
          $rootScope.$broadcast 'userData', data.data
          TweetService.getUserTimeline(twitterIdStr: scope.twitterIdStr)
        .then (data) ->
          console.log data.data
          $rootScope.$broadcast 'tweetData', data.data


  # 動かなくなった。
  .directive 'newTweetLoad', ($rootScope, TweetService) ->
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
