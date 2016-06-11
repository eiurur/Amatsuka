angular.module "myApp.directives"
  .directive 'showUserSidebar', ($rootScope, TweetService, WindowScrollableSwitcher) ->
    restrict: 'A'
    scope:
      twitterIdStr: '@'
    link: (scope, element, attrs) ->


      showUserSidebar = ->
        TweetService.showUsers(twitterIdStr: scope.twitterIdStr)
        .then (data) ->
          console.log data
          $rootScope.$broadcast 'showUserSidebar::userData', data.data
          TweetService.getUserTimeline(twitterIdStr: scope.twitterIdStr)
        .then (data) ->
          console.log data.data
          $rootScope.$broadcast 'showUserSidebar::tweetData', data.data

      element.on 'click', ->
        $rootScope.$broadcast 'showUserSidebar::isOpened', true
        $document = angular.element(document)

        domUserSidebar       =  $document.find('.user-sidebar')
        domUserSidebarHeader =  $document.find('.user-sidebar__header')

        # user-sidebarが開かれた状態で呼び出しされたら、
        # サイドバーを維持したまま他のユーザのツイートとプロフィールを表示
        isOpenedSidebar =　domUserSidebar[0].className.indexOf('.user-sidebar--in') isnt -1
        if isOpenedSidebar
          do showUserSidebar
          return

        ###
        初回(サイドバーは見えない状態が初期状態)
        ###
        domUserSidebar.addClass('user-sidebar--in')
        domUserSidebarHeader.removeClass('user-sidebar__controll--out')

        # bodyのスクロールバーを除去
        body =  $document.find('body')
        body.addClass('scrollbar-y-hidden')

        WindowScrollableSwitcher.disableScrolling()

        # 背景を半透明黒くして邪魔なものを隠す
        layer =  $document.find('.layer')
        layer.addClass('fullscreen-overlay')

        # 表示
        do showUserSidebar

        # クリックされたらサイドバーを閉じる
        layer.on 'click', ->
          body.removeClass('scrollbar-y-hidden')
          layer.removeClass('fullscreen-overlay')
          domUserSidebar.removeClass('user-sidebar--in')
          domUserSidebarHeader.addClass('user-sidebar__controll--out')
          WindowScrollableSwitcher.enableScrolling()

          $rootScope.$broadcast 'showUserSidebar::isClosed', true
          return
