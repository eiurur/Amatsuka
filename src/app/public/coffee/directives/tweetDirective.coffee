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
        console.log 'favorited = ', scope.favorited
        if scope.favorited
          element.removeClass('favorited')
          TweetService.destroyFav(tweetIdStr: scope.tweetIdStr)
            .then (data) ->
              scope.favNum -= 1
              scope.favorited = !scope.favorited
        else
          element.addClass('favorited')
          TweetService.createFav(tweetIdStr: scope.tweetIdStr)
            .then (data) ->
              scope.favNum += 1
              scope.favorited = !scope.favorited

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
              scope.retweeted = !scope.retweeted

        else if window.confirm('リツイートしてもよろしいですか？')
          element.addClass('retweeted')
          TweetService.retweetStatus(tweetIdStr: scope.tweetIdStr)
            .then (data) ->
              scope.retweetNum += 1
              scope.retweeted = !scope.retweeted

  .directive 'followable', ($rootScope, ListService, TweetService) ->
    restrict: 'E'
    replace: true
    scope:
      listIdStr: '@'
      twitterIdStr: '@'
      followStatus: '='
    template: '<span class="label label-default timeline__header__label">{{content}}</span>'
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
            ListService.addMember(scope.twitterIdStr)
            $rootScope.$broadcast 'addMember', scope.twitterIdStr
            console.log 'E followable createListsMembers data', data

            TweetService.collectProfile(twitterIdStr: scope.twitterIdStr)
          .then (data) ->
            console.log data

  .directive 'followable', ($rootScope, ListService, TweetService) ->
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
          element[0].innerText = 'フォロー'
          TweetService.destroyListsMembers(opts)
          .then (data) ->
            console.log data
            ListService.removeMember(scope.twitterIdStr)
            $rootScope.$broadcast 'list:removeMember', data
            scope.isProcessing = false

        if scope.followStatus is false
          element[0].innerText = 'フォロー解除'
          TweetService.createListsMembers(opts)
          .then (data) ->
            ListService.addMember(scope.twitterIdStr)
            $rootScope.$broadcast 'addMember', scope.twitterIdStr
            $rootScope.$broadcast 'list:addMember', data
            scope.isProcessing = false

            TweetService.collectProfile(twitterIdStr: scope.twitterIdStr)
          .then (data) ->
            console.log data

        scope.followStatus = !scope.followStatus
