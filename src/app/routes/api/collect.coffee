_              = require 'lodash'
path           = require 'path'
PictCollection = require path.resolve 'build', 'lib', 'PictCollection'
{PictProvider} = require path.resolve 'build', 'lib', 'model'
settings       = if process.env.NODE_ENV is 'production'
  require path.resolve 'build', 'lib', 'configs', 'production'
else
  require path.resolve 'build', 'lib', 'configs', 'development'


# JSON API
module.exports = (app) ->

  app.get '/api/collect/count', (req, res) ->
    PictProvider.count()
    .then (count) ->
      res.json count: count
    .catch (err) ->
      console.log err

  app.get '/api/collect/:skip?/:limit?', (req, res) ->
    PictProvider.find
      skip: req.params.skip - 0
      limit: req.params.limit - 0
    .then (data) ->
      res.send data

  app.post '/api/collect/profile', (req, res) ->
    pictCollection = new PictCollection(req.session.passport.user, req.body.twitterIdStr)

    # フォローしたユーザをデータベースに保存
    pictCollection.getIllustratorTwitterProfile()
    .then (data) -> pictCollection.setIllustratorRawData(data)
    .then -> pictCollection.getIllustratorRawData()
    .then (illustratorRawData) -> pictCollection.setUserTimelineMaxId(illustratorRawData.status.id_str)
    .then -> pictCollection.normalizeIllustratorData()
    .then -> pictCollection.updateIllustratorData()
    .then (data) -> pictCollection.setIllustratorDBData(data)
    .then (data) ->
      console.log 'End PictProvider.findOneAndUpdate data = ', data
      res.send data
    .catch (err) ->
      console.log err