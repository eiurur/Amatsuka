# Directives
angular.module "myApp.directives"
  .directive 'dotLoader', () ->
      restrict: 'E'
      template: '''
        <div class="wrapper">
          <div class="dot"></div>
          <div class="dot"></div>
          <div class="dot"></div>
        </div>
      '''

  .directive "imgPreload", ->
    restrict: "A"
    link: (scope, element, attrs) ->
      element.on("load", ->
        element.addClass "in"
        return
      ).on "error", ->
      return

  .directive "scrollOnClick", ->
    restrict: "A"
    scope:
      scrollTo: "@"
      speed: "@"
    link: (scope, element, attrs) ->
      element.on 'click', ->
        speed = scope.speed or 0
        $('html, body').animate
          scrollTop: $(scope.scrollTo).offset().top, speed

  .directive 'downloadFromUrl', ($q, toaster, DownloadService) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      element.on 'click', (event) ->
        toaster.pop 'wait', "Now Downloading ...", '', 0, 'trustedHtml'

        # findページでダウンロードボタンが押された場合は単発固定 + 文字列で渡される よってJSON.parseすると ["h", "t", ~]の形になり以降の処理に失敗する
        # その他からは"[~]"の形で渡されるため、処理を分岐させる。
        # urlList = if attrs.url.indexOf('[') is -1 then [attrs.url] else JSON.parse(attrs.url)
        promises = []
        if attrs.url.indexOf('[') is -1
          idx = attrs.imgIdx or 0
          promises.push DownloadService.exec(attrs.url, attrs.filename, idx)
        else
          JSON.parse(attrs.url).forEach (url, idx) ->
            promises.push DownloadService.exec(url, attrs.filename, idx)

        $q.all promises
        .then (datas) ->
          toaster.clear()
          toaster.pop 'success', "Finished Download", '', 2000, 'trustedHtml'

  .directive 'icNavAutoclose', ->
    console.log 'icNavAutoclose'
    (scope, elm, attrs) ->
      collapsible = $(elm).find('.navbar-collapse')
      visible = false

      collapsible.on 'show.bs.collapse', ->
        visible = true
        return

      collapsible.on 'hide.bs.collapse', ->
        visible = false
        return

      $(elm).find('a').each (index, element) ->
        $(element).click (e) ->
          return if e.target.className.indexOf('dropdown-toggle') isnt -1
          if visible and 'auto' == collapsible.css('overflow-y')
            collapsible.collapse 'hide'
          return
        return
      return

  .directive 'clearLocalStorage', (toaster) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      element.on 'click', (event) ->
        toaster.pop 'wait', "Now Clearing ...", '', 0, 'trustedHtml'
        window.localStorage.clear()
        toaster.clear()
        toaster.pop 'success', "Finished clearing the list data", '', 2000, 'trustedHtml'

  # http://liginc.co.jp/web/js/other-js/137655
  .directive 'log', ($analytics) ->
    restrict: 'A'
    link: (scope, element, attrs) ->

      clickHandler = (e) ->
        params = attrs.log
        if !params
          return
        params = params.split(',')
        options = {}
        if params[1]
          options.category = params[1]
        if params[2]
          options.label = params[2]
        $analytics.eventTrack params[0], options
        return

      element.on 'click', clickHandler
      scope.$on '$destroy', ->
        element.off 'click', clickHandler
        return
      return