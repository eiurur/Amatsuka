path         = require 'path'
_            = require 'lodash'
ModelFactory = require path.resolve 'build', 'model', 'ModelFactory'

module.exports =

  getConfig: (req, res, next) ->
    opts = twitterIdStr: req.session.passport.user._json.id_str
    ModelFactory.create('config').findOneById opts
    .then (data) ->
      # 設定データが未登録
      config = if _.isNull data then {} else JSON.parse(data.configStr)
      req.config = config
      next()

  # # tokenが一致するか確認するミドルウェア
  # getToken:  (req, res, next) ->
  #   new DatabaseManagers.UserCollectionManager().__findByAccessToken req.body.token
  #   .then (user) ->
  #     console.log '======> findByAccessToken user', user
  #     if _.isNull user
  #       res.status(401).json statusText: "Error: トークンに誤りがあります。\nもう一度確認してみてください。"
  #     else
  #       console.log 'next()'
  #       req.user = user
  #       next()
  #   return