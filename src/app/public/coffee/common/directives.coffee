# Directives
angular.module "myApp.directives", []
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
    link: (scope, element, attrs) ->
      element.on 'click', ->
        $('html, body').animate
          scrollTop: $(scope.scrollTo).offset().top, "slow"

  .directive 'resize', ($timeout, $rootScope, $window) ->
    link: ->
      timer = false
      angular.element($window).on 'load resize', (e) ->
        if timer then $timeout.cancel timer

        timer = $timeout ->

          # ウィンドウのサイズを取得
          html = angular.element(document).find('html')
          cW = html[0].clientWidth
          console.log 'broadCast resize ', cW

          # ウィンドウのサイズを元にビューを切り替える
          # 2カラムで表示できる限界が700px
          layoutType = if cW < 700 then 'list' else 'grid'

          $rootScope.$broadcast 'resize::resize', layoutType: layoutType

        , 200
        return

  .directive "zoomImage", ($rootScope, TweetService) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      html = ''

      # 画像プリロード(押してから表示するより体感速度的に高速)
      element.on 'mouseenter', ->
        imageLayer = angular.element(document).find('.image-layer')
        html = """
          <div class="image-layer__container">
            <img
              src="#{attrs.imgSrc}:orig"
              class="image-layer__img image-layer__img--hidden" />

          </div>
          """
        imageLayer.html html

      element.on 'click', ->

        # windowのサイズを取得
        html = angular.element(document).find('html')

        # 画面全体をオーバーレイで覆う
        imageLayer = angular.element(document).find('.image-layer')
        imageLayer.addClass('image-layer__overlay')

        # 拡大画像の表示
        imageLayerImg = angular.element(document).find('.image-layer__img')
        imageLayerImg.removeClass('image-layer__img--hidden')
        return unless imageLayerImg[0].naturalHeight?

        # 拡大画像の伸長方向の決定
        h = imageLayerImg[0].naturalHeight
        w = imageLayerImg[0].naturalWidth
        h_w_percent = h / w * 100

        cH = html[0].clientHeight
        cW = html[0].clientWidth
        cH_cW_percent = cH / cW * 100

        direction = if h_w_percent - cH_cW_percent >= 0 then 'h' else 'w'

        imageLayerImg.addClass("image-layer__img-#{direction}-wide")

        # オーバーレイ部分をクリックしたら生成した要素は全て削除する
        imageLayerContainer = angular.element(document).find('.image-layer__container')
        imageLayerContainer.on 'click', ->
          imageLayer.html ''
          imageLayer.removeClass('image-layer__overlay')

  .directive 'downloadFromUrl', ($q, toaster, DownloadService, ConvertService) ->
    restrict: 'A'
    link: (scope, element, attrs) ->


      element.on 'click', (event) ->

        # findは単発固定 + 文字列で渡される -> JSON.parseすると ["h", "t", ~]の形になり以降の処理に失敗する
        # その他からは"[~]"の形で渡されるため、そこで処理を分岐させる。
        urlList = if attrs.url.indexOf('[') is -1 then [attrs.url] else JSON.parse(attrs.url)
        promises = []

        # promises = urlList.map (url, idx) ->
        #   console.log idx url
        #   _.partial exec, url , idx

        toaster.pop 'wait', "Now Downloading ...", '', 0, 'trustedHtml'
        # urlList.forEach (url, idx) ->
        #   # exec.bind(null, url, idx)()
        #   DownloadService.exec(url, idx)


        # for url, idx in urlList then do (url, idx) ->
        #   console.log idx, url
        #   DownloadService.exec(attrs.filename, url, idx)

        # url = null
        # idx = null

        # console.log promises
        # #   exec.bind(null, url, idx)()
        #   # promises.push exec.bind(null, url, idx)

        #   # # これがないと動かない
        #   # promises[idx]()

        # # download属性に比べてはるかに時間がかかるので通知を出す。
        # toaster.pop 'wait', "Now Downloading ...", '', 0, 'trustedHtml'
        promises = urlList.map (url) -> url: url, func: DownloadService.exec(url)
        console.log promises
        console.log _.pluck(promises, 'func')
        $q.all _.pluck(promises, 'func')
        # Promise.all(promises)
        .then (resultList) ->
          console.log resultList
          console.log promises
          resultList.forEach (result, idx) ->
            blob = ConvertService.base64toBlob result.data.base64Data
            url = promises[idx].url
            ext = /media\/.*\.(png|jpg|jpeg):orig/.exec(url)[1]
            filename = "#{attrs.filename}_#{idx}.#{ext}"
            console.log idx, url, ext, filename
            DownloadService.saveAs blob, filename

          # Fix: 複数DL中に一つ終えると全部のtoasterが消える。
          toaster.clear()

          # DL終了を通知
          toaster.pop 'success', "Finished Download", '', 2000, 'trustedHtml'

            # DownloadService.exec(url)
            # .success (data) ->
            #   blob = ConvertService.base64toBlob data.base64Data
            #   ext = /media\/.*\.(png|jpg|jpeg):orig/.exec(url)[1]
            #   filename = "#{attrs.filename}_#{idx}.#{ext}"
            #   saveAs blob, filename

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
