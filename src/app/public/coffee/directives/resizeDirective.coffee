angular.module "myApp.directives"
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
          # layoutType = if cW < 700 then 'list' else 'grid'
          layoutType = if cW < 700 then 'list' else 'tile'

          $rootScope.$broadcast 'resize::resize', layoutType: layoutType

        , 200
        return