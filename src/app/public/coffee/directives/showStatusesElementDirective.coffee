# angular.module 'myApp.directives'
#   .directive 'showStatusesElement', ($compile, TweetService) ->
#     restrict: 'E'
#     scope: {}
#     template: """"
#       <div class="image-layer__caption">
#         <div class="timeline__post--footer">
#           <div class="timeline__post--footer--contents">
#             <div class="timeline__post--footer--contents--controls">
#               <a href="#{data.data.entities.media[0].expanded_url}" target="_blank">
#                 <i class="fa fa-twitter icon-twitter"></i>
#               </a>
#               <i class="fa fa-retweet icon-retweet" tweet-id-str="#{data.data.id_str}" retweeted="#{data.data.retweeted}" retweetable="retweetable"></i>
#               <i class="fa fa-heart icon-heart" tweet-id-str="#{data.data.id_str}" favorited="#{data.data.favorited}" favoritable="favoritable"></i>
#               <a><i class="fa fa-download" data-url="#{data.data.extended_entities.media[0].media_url_https}:orig" filename="#{data.data.user.screen_name}_#{data.data.id_str}" download-from-url="download-from-url"></i></a>
#             </div>
#           </div>
#         </div>
#       </div>
#     """
#     bindToController:
#       tweetIdStr: "="
#     controller: ShowStatusesElementController
#     controllerAs: '$ctrl'
#     link: (scope, element, attrs, $ctrl) ->
#       element.on 'click', (event) =>
#         TweetService.showStatuses(tweetIdStr: @tweetIdStr)
#         .then (data) ->
#           console.log 'showStatusesElement', data

#           # imageLayer = angular.element(document).find('.image-layer')

#           # 読み込み前に拡大画像を閉じた場合はcaptionタグを表示させない
#           # return if _.isEmpty(imageLayer.html())
#           # item = $compile(imageLayerCaptionHtml)(scope).hide().fadeIn(300)
#           # imageLayer.append(item)
# class ShowStatusesElementController