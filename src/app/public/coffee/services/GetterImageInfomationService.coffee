angular.module 'myApp.services'
  .service 'GetterImageInfomation', ->
    # 拡大画像の伸長方向の決定
    getWideDirection: (imgElement, html) ->

      h = imgElement[0].naturalHeight
      w = imgElement[0].naturalWidth
      h_w_percent = h / w * 100

      cH = html[0].clientHeight
      cW = html[0].clientWidth
      cH_cW_percent = cH / cW * 100

      direction = if h_w_percent - cH_cW_percent >= 0 then 'h' else 'w'