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

  .directive "zoomImage", ($rootScope, TweetService) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      html =  ''

      # 画像プリロード(押してから表示するより体感速度的に高速)
      element.on 'mouseenter', ->
        imageLayer = angular.element(document).find('.image-layer')
        html = """
          <img
            src="#{attrs.imgSrc}:orig"
            class="image-layer__img image-layer__img--hidden" />
          """
        imageLayer.html html
        # console.log 'imageLayer', imageLayer
        # console.log(imageLayer[0].children[0].naturalHeight)
        # console.log(imageLayer[0].children[0].naturalWidth)

      element.on 'click', ->
        imageLayer = angular.element(document).find('.image-layer')
        imageLayer.addClass('image-layer__overlay')

        imageLayerImg = angular.element(document).find('.image-layer__img')
        imageLayerImg.removeClass('image-layer__img--hidden')
        return unless imageLayerImg[0].naturalHeight?

        # console.log imageLayerImg
        # console.log imageLayerImg[0].naturalHeight
        # console.log imageLayerImg[0].naturalWidth

        # 画面に綺麗に収まるようimgのサイズを設定する処理
        # XXX:
        # スマホだとhoverイベントをキャッチできず 画像のサイズが分からないのでPCだけの機能とする、
        # TODO:
        # ngTouchとか使ってスマホにも対応。
        h = imageLayerImg[0].naturalHeight
        w = imageLayerImg[0].naturalWidth
        dirction = if h > w then 'h' else 'w'
        imageLayerImg.addClass("image-layer__img-#{dirction}-wide")

        imageLayer.on 'click', ->
          imageLayer.html ''
          imageLayer.removeClass('image-layer__overlay')
