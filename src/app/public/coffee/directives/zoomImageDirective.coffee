angular.module "myApp.directives"
  .directive "zoomImage", ($compile, $rootScope, TweetService, GetterImageInfomation) ->
    restrict: 'A'
    link: (scope, element, attrs) ->

      element.on 'click', ->
        # todo: 各アクションで画像の切替が可能なバージョン。ただし、重くて使い物にはならないのでいったんコメントアウト
        # $rootScope.$broadcast 'zoomableImage::show', tweets: scope.tweets, attrs: attrs

        imageLayer = angular.element(document).find('.image-layer')
        containerHTML = """
          <div class="image-layer__container">
            <img class="image-layer__img"/>
            <div class="image-layer__loading">
              <img src="./images/loaders/tail-spin.svg" />
            </div>
          </div>
          """
        imageLayer.html containerHTML

        # 画面全体をオーバーレイで覆う
        imageLayer.addClass('image-layer__overlay')

        imageLayerImg = angular.element(document).find('.image-layer__img')
        imageLayerLoading = angular.element(document).find('.image-layer__loading')

        # 画像はいったん非表示(横に伸びた画像が表示された後にリサイズされる動作をするのだけど、それが煩い)
        imageLayerImg.hide()

        imageLayerImg
        .attr 'src', "#{attrs.imgSrc}".replace ':small', ':orig'
        .load ->
          direction = GetterImageInfomation.getWideDirection(imageLayerImg)
          imageLayerImg.addClass("image-layer__img-#{direction}-wide")

          # 満を持して表示
          imageLayerLoading.remove()
          imageLayerImg.fadeIn(500)

        # オーバーレイ部分をクリックしたら生成した要素は全て削除する
        imageLayerContainer = angular.element(document).find('.image-layer__container')
        imageLayerContainer.on 'click', ->
          imageLayer.html ''
          imageLayer.removeClass('image-layer__overlay')