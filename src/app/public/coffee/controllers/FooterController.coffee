# angular.module "myApp.controllers"
#   .controller "FooterCtrl", (
#     ) ->
#     console.log 'FooterCtrl'

#     this.isShowControlButton        = true
#     this.isOpenPostControlContainer = false
#     _document = angular.element(document)

#     postsControlContainer          = _document.find('.posts-control__container')
#     buttonOpenPostControlContainer = _document.find('.button--open__post-contorol-container')
#     buttonOpenPostControlContainer.on 'click', ->
#       this.isOpenPostControlContainer = true
#       html = _document.find('html')

#       # 画面全体を覆う透明のオーバーレイ要素を生成
#       overlayHTML = "<div class='posts-control__container__overlay'></div>"
#       html.append overlayHTML
#       postsControlContainerOverlay = _document.find('.posts-control__container__overlay')

#       # オーバーレイ要素をクリック === ControlContainer以外をクリック なら controlContainerを閉じる
#       postsControlContainerOverlay.on 'click', =>
#         console.log 'click overlay'
#         postsControlContainerOverlay.off()  # これ必要？
#         postsControlContainerOverlay.remove()
#         this.isOpenPostControlContainer = false
#         this.$apply()
#       this.$apply()
#       return
