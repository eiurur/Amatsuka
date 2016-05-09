# Viewwe
# KeyCommander
# DataManager
angular.module "myApp.factories"
  .factory 'ZoomImageViewer', (GetterImageInfomation) ->
    class ZoomImageViewer

      # Containerを表示
      # 黒半透明の要素で画面全体を覆う
      # 画像はいったん非表示
      # 画像を読み込んでアサイン
      #

      constructor: ->
        # windowのサイズを取得
        @html = angular.element(document).find('html')
        @body = angular.element(document).find('body')

        @imageLayer = angular.element(document).find('.image-layer')
        containerHTML = """
          <div class="image-layer__container">
            <img class="image-layer__img"/>
            <div class="image-layer__loading">
              <img src="./images/loaders/tail-spin.svg" />
            </div>
          </div>

          """
        @imageLayer.html containerHTML

        # 画面全体をオーバーレイで覆う
        @imageLayer.addClass('image-layer__overlay')

        @imageLayerImg = angular.element(document).find('.image-layer__img')
        @imageLayerLoading = angular.element(document).find('.image-layer__loading')

      setImageAndStyle: (imgElement, html) ->
        direction = GetterImageInfomation.getWideDirection(imgElement, html)
        imgElement.addClass("image-layer__img-#{direction}-wide")

      pipeLowToHighImage: (from, to) ->
        @imageLayerLoading.show()
        @imageLayerImg.hide()
        @imageLayerImg.removeClass()

        @imageLayerImg
        .attr 'src', from
        .load =>
          console.log '-> Middle'
          @imageLayerLoading.hide()
          @setImageAndStyle(@imageLayerImg, @html)
          @imageLayerImg.fadeIn(1)

          # loadの∞ループ回避
          @imageLayerImg.off 'load'

          @imageLayerImg
          .attr 'src', to
          .load =>
            console.log '-> High'
            # @setImageAndStyle(@imageLayerImg, @html)
            @imageLayerImg.fadeIn(1)


      cleanup: ->
        @imageLayerLoading.remove()
        @imageLayer.removeClass('image-layer__overlay')

    ZoomImageViewer