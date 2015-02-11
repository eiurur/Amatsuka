# Directives
angular.module "myApp.directives", []
  .directive 'boxLoading', ($interval) ->
    restrict: 'E'
    link: (scope, element, attrs) ->
      tag = '''
        <div class="box-loader">
          <b></b>
          <b></b>
          <b></b>
          <b></b>
          <b></b>
          <b></b>
          <b></b>
          <b></b>
          <b></b>
        </div>
        '''
      element.append tag

      count = 0
      allocations = [0,1,2,5,8,7,6,3]
      rotate = ->
        bs = element.find 'b'
        _.map bs, (elem) ->
          elem.style.background = attrs.base
        bs[allocations[count]].style.background = attrs.highlight
        count++
        if count is 8 then count = 0
      animate = $interval rotate, 150

  .directive "slideable", ->
    restrict: "C"
    compile: (element, attr) ->
      contents = element.html()
      element.html """
        <div class='slideable_content'
          style='margin:0 !important; padding:0 !important'>
          #{contents}
        </div>
        """
      postLink = (scope, element, attrs) ->
        console.log attrs
        attrs.duration = unless attrs.duration then "0.4s" else attrs.duration
        attrs.easing =
          unless attrs.easing then "ease-in-out" else attrs.easing
        element.css
          overflow: "hidden"
          height: "0px"
          transitionProperty: "height"
          transitionDuration: attrs.duration
          transitionTimingFunction: attrs.easing
      return

  .directive "slideToggle", ->
    restrict: "A"
    link: (scope, element, attrs) ->
      target = undefined
      content = undefined
      attrs.expanded = false
      element.bind "click", ->
        target = document.querySelector(attrs.slideToggle)  unless target
        content = target.querySelector(".slideable_content")  unless content
        unless attrs.expanded
          content.style.border = "1px solid rgba(0,0,0,0)"
          y = content.clientHeight
          content.style.border = 0
          target.style.height = y + "px"
        else
          target.style.height = "0px"
        attrs.expanded = not attrs.expanded

  .directive "imgPreload", ->
    restrict: "A"
    link: (scope, element, attrs) ->
      element.on("load", ->
        element.addClass "in"
      ).on "error", ->

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
      element.on 'mouseover', ->
        imageLayer = angular.element(document).find('.image-layer')
        html = """
          <img src="#{attrs.imgSrc}:orig" class="image-layer__img image-layer__img--hidden" />
          """
        imageLayer.html html

      element.on 'click', ->
        imageLayer = angular.element(document).find('.image-layer')
        imageLayer.addClass('image-layer__overlay')

        imageLayerImg = angular.element(document).find('.image-layer__img')
        imageLayerImg.removeClass('image-layer__img--hidden')

        imageLayer.on 'click', ->
          imageLayer.html ''
          imageLayer.removeClass('image-layer__overlay')
