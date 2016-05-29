# angular.module "myApp.directives"
#   .directive 'zoomImageContainer', ->
#     restrict: 'E'
#     scope: {}
#     template: """
#       <span ng-show="$ctrl.isShown">
#         <div class="layer">
#         </div>
#         <div class="image-layer image-layer__overlay">
#           <div class="image-layer__container" ng-click="$ctrl.cleanup()">

#             <img class="image-layer__img" src="$ctrl.tweetImage"/>

#             <div ng-show="$ctrl.isShownLoading" class="image-layer__loading">
#               <img src="./images/loaders/tail-spin.svg" />
#             </div>

#             <div class="image-layer__prev" ng-click="$ctrl.switchImage('prev')">
#               <i class="fa fa-angle-left fa-2x feeding-arrow"></i>
#             </div>
#             <div class="image-layer__next" ng-click="$ctrl.switchImage('next')">
#               <i class="fa fa-angle-right fa-2x feeding-arrow feeding-arrow-right__patch"></i>
#             </div>

#           </div>

#           <div class="image-layer__caption">
#             <div class="timeline__footer">
#               <div class="timeline__footer__contents">
#                 <div class="timeline__footer__controls">
#                   <a href="$ctrl.tweet.extended_entities.media[imgIdx].expanded_url" target="_blank">
#                     <i class="fa fa-twitter icon-twitter"></i>
#                   </a>
#                   <i class="fa fa-retweet icon-retweet" tweet-id-str="$ctrl.tweet.id_str" retweeted="$ctrl.tweet.retweeted" retweetable="retweetable"></i>
#                   <i class="fa fa-heart icon-heart" tweet-id-str="$ctrl.tweet.id_str" favorited="tweet.favorited" favoritable="favoritable"></i>
#                   <a>
#                     <i class="fa fa-download" data-url="$ctrl.tweet.extended_entities.media[imgIdx].media_url_https}:orig" filename="$ctrl.tweet.user.screen_name_$ctrl.tweet.id_str" download-from-url="download-from-url"></i>
#                   </a>
#                 </div>
#               </div>
#             </div>
#           </div>

#         </div>
#       </span>
#     """
#     bindToController: {}
#     controllerAs: "$ctrl"
#     controller: ZoomImageContainerController

# class ZoomImageContainerController
#   constructor: (@$location, @$scope, @ListService, @TweetService, @WindowScrollableSwitcher) ->
#     # windowのサイズを取得
#     @html    = angular.element(document).find('html')
#     @body    = angular.element(document).find('body')
#     @tweet   = null

#     @isShown = false
#     @isShownLoading = false
#     do @subscribe

#   # スクロールバインド
#   bindScrollEvent: ->

#   # キーバインド
#   # j, k, ->, <-, f, r, t, d
#   bindKeyEvent: ->
#     Mousetrap.bind 'd', -> angular.element(document).find('.image-layer__caption .fa-download').click()
#     Mousetrap.bind 'f', -> angular.element(document).find('.image-layer__caption .icon-heart').click()
#     Mousetrap.bind 'r', -> angular.element(document).find('.image-layer__caption .icon-retweet').click()
#     Mousetrap.bind 't', -> angular.element(document).find('.image-layer__caption .fa-twitter').click()
#     Mousetrap.bind ['esc', 'q'], => cleanup()
#     console.log @tweet

#     return if @tweet.extended_entities.media.length < 2

#     Mousetrap.bind ['left', 'k'], => @switchImage('prev')
#     Mousetrap.bind ['right', 'j'], => @switchImage('next')

#     # ScrollEvent
#     imageLayerContainer = angular.element(document).find('.image-layer__container')
#     imageLayerContainer.on 'wheel', (e) =>
#       # e.originalEvent.wheelDelta >= 0  === Scroll up
#       dir = if e.originalEvent.wheelDelta >= 0 then 'prev' else 'next'
#       @switchImage(dir)

#   cleanup: ->
#     Mousetrap.unbind ['left', 'right', 'esc', 'd', 'f', 'j', 'k', 'q', 'r', 't']
#     @WindowScrollableSwitcher.enableScrolling()
#     @isShown = false
#     @isShownLoading = false

#   switchImage: ->
#     console.log 'SWW'

#   subscribe: ->

#     # 画像がクリックされたら表示
#     @$scope.$on 'zoomableImage::show', (event, args) =>
#       @isShown = true
#       @isShownLoading = true
#       @WindowScrollableSwitcher.disableScrolling()

#       [from, to] = [args.imgSrc, args.imgSrc.replace(':small', ':orig')]
#       @pipeLowToHighImage(from, to)


#       @TweetService.showStatuses(tweetIdStr: args.tweetIdStr)
#       .then (data) =>
#         @tweet = data.data
#         @bindKeyEvent()

#   setImageAndStyle: (imgElement, html) ->

#     # 拡大画像の伸長方向の決定
#     h = imgElement[0].naturalHeight
#     w = imgElement[0].naturalWidth
#     h_w_percent = h / w * 100

#     cH = html[0].clientHeight
#     cW = html[0].clientWidth
#     cH_cW_percent = cH / cW * 100

#     direction = if h_w_percent - cH_cW_percent >= 0 then 'h' else 'w'

#     imgElement.addClass("image-layer__img-#{direction}-wide")

#   pipeLowToHighImage: (from, to) ->
#     console.log from, to

#     @tweetImage = from
#     @isShownLoading = false
#     @imageLayerImg = angular.element(document).find('.image-layer__img')
#     @imageLayerImg.removeClass()

#     @setImageAndStyle(@imageLayerImg, @html)
#     @imageLayerImg.fadeIn(1)

#     @imageLayerImg
#     .attr 'src', to
#     .load =>
#       console.log '-> High'
#       # @setImageAndStyle(@imageLayerImg, @html)
#       @imageLayerImg.fadeIn(1)

# ZoomImageContainerController.$inject = ['$location', '$scope', 'ListService', 'TweetService', 'WindowScrollableSwitcher']