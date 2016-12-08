angular.module "myApp.directives"
  .directive 'showDrawer', ($rootScope, TweetService, WindowScrollableSwitcher) ->
    restrict: 'A'
    scope:
      twitterIdStr: '@'
    link: (scope, element, attrs) ->


      showDrawer = ->
        TweetService.showUsers(twitterIdStr: scope.twitterIdStr)
        .then (data) ->
          console.log data
          $rootScope.$broadcast 'showDrawer::userData', data.data
          TweetService.getUserTimeline(twitterIdStr: scope.twitterIdStr)
        .then (data) ->
          console.log data.data
          $rootScope.$broadcast 'showDrawer::tweetData', data.data

      element.on 'click', ->
        $rootScope.$broadcast 'showDrawer::isOpened', true
        $document = angular.element(document)

        domDrawer       =  $document.find('.drawer')
        domDrawerHeader =  $document.find('.drawer__header')

        # drawerが開かれた状態で呼び出しされたら、
        # サイドバーを維持したまま他のユーザのツイートとプロフィールを表示
        isOpenedSidebar =　domDrawer[0].className.indexOf('.drawer--in') isnt -1
        if isOpenedSidebar
          do showDrawer
          return

        ###
        初回(サイドバーは見えない状態が初期状態)
        ###
        domDrawer.addClass('drawer--in')
        domDrawerHeader.removeClass('drawer__controll--out')

        # bodyのスクロールバーを除去
        body =  $document.find('body')
        body.addClass('scrollbar-y-hidden')

        WindowScrollableSwitcher.disableScrolling()

        # 背景を半透明黒くして邪魔なものを隠す
        layer =  $document.find('.layer')
        layer.addClass('fullscreen-overlay')

        # 表示
        do showDrawer

        # クリックされたらサイドバーを閉じる
        layer.on 'click', ->
          body.removeClass('scrollbar-y-hidden')
          layer.removeClass('fullscreen-overlay')
          domDrawer.removeClass('drawer--in')
          domDrawerHeader.addClass('drawer__controll--out')
          WindowScrollableSwitcher.enableScrolling()

          $rootScope.$broadcast 'showDrawer::isClosed', true
          return
