angular.module "myApp.directives"
  .directive 'zoomImageContainer', ->
    restrict: 'E'
    scope: {}
    template: """
      <span ng-show="$ctrl.isShown">
        <div class="layer">
        </div>
        <div class="image-layer image-layer__overlay">
          <div class="image-layer__container">
            <img class="image-layer__img"/>
            <div class="image-layer__loading">
              <img src="./images/loaders/tail-spin.svg" />
            </div>
          </div>
        </div>
      </span>
    """
    bindToController: {}
    controllerAs: "$ctrl"
    controller: ZoomImageContainerController

class ZoomImageContainerController
  constructor: (@$location, @$scope, @ListService) ->

    @isShown = false

    # windowのサイズを取得
    @html = angular.element(document).find('html')
    @body = angular.element(document).find('body')
    @imageLayerImg = angular.element(document).find('.image-layer__img')
    @imageLayerLoading = angular.element(document).find('.image-layer__loading')
    @imageLayerContainer = angular.element(document).find('.image-layer__container')

    # do pipeLowToHighImage()
    # do @bindScrollEvent
    # do @bindKeyEvent
    do @subscribe

  # スクロールバインド
  bindScrollEvent: ->

  # キーバインド
  # j, k, ->, <-, f, r, t, d
  bindKeyEvent: ->

  bindClickEvent: ->
    @imageLayerContainer.on 'click', =>
      @isShown = false

  subscribe: ->

    # 画像がクリックされたら表示
    @$scope.$on 'zoomableImage::show', (event, args) =>
      console.log args
      console.log args.attrs.imgSrc

      @isShown = true
      [from, to] = [args.attrs.imgSrc, args.attrs.imgSrc.replace(':small', ':orig')]
      @pipeLowToHighImage(from, to)


      do @bindClickEvent



  setImageAndStyle: (imgElement, html) ->

    # 拡大画像の伸長方向の決定
    h = imgElement[0].naturalHeight
    w = imgElement[0].naturalWidth
    h_w_percent = h / w * 100

    cH = html[0].clientHeight
    cW = html[0].clientWidth
    cH_cW_percent = cH / cW * 100

    direction = if h_w_percent - cH_cW_percent >= 0 then 'h' else 'w'

    imgElement.addClass("image-layer__img-#{direction}-wide")

  pipeLowToHighImage: (from, to) ->
    @imageLayerLoading.show()
    @imageLayerImg.hide()
    @imageLayerImg.removeClass()
    console.log from, to

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
        @setImageAndStyle(@imageLayerImg, @html)
        @imageLayerImg.fadeIn(1)

ZoomImageContainerController.$inject = ['$location', '$scope', 'ListService']