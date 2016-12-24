_              = require 'lodash'
path           = require 'path'
PictCollection = require path.resolve 'build', 'lib', 'PictCollection'
{PictProvider, IllustratorProvider} = require path.resolve 'build', 'lib', 'model'
{settings}     = require path.resolve 'build', 'lib', 'configs', 'settings'


# JSON API
module.exports = (app) ->

  app.get '/api/collect/count', (req, res) ->
    PictProvider.count()
    .then (count) ->
      res.json count: count
    .catch (err) ->
      console.log err

  app.get '/api/collect/picts', (req, res) ->
    console.log '/api/collect/picts/ req.query.twitterIdStr =', req.query.twitterIdStr
    IllustratorProvider.findById
      twitterIdStr: req.query.twitterIdStr
    .then (illustrator) ->
      console.log 'IllustratorProvider.findById result = ', illustrator
      unless illustrator?
        res.status(400).send(null)
        return
      console.log 'PictProvider.findByIllustratorObjectId --->'
      console.log illustrator?
      console.log illustrator._id

      PictProvider.findByIllustratorObjectId
        postedBy: illustrator._id
    .then (data) ->
      console.log data
      console.log data.postedBy
      console.log data.pictTweetList.length
      res.send data
    .catch (err) ->
      console.error 'app.get /api/collect/picts/ error ', err
      res.status(400).send(err)

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