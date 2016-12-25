path           = require 'path'
PictCollection = require path.resolve 'build', 'lib', 'PictCollection'
ModelFactory   = require path.resolve 'build', 'model', 'ModelFactory'

module.exports = (app) ->

  app.get '/api/collect/count', (req, res) ->
    ModelFactory.create('pict').count()
    .then (count) ->
      res.json count: count
    .catch (err) ->
      console.log err

  app.get '/api/collect/picts', (req, res) ->
    console.log '/api/collect/picts/ req.query.twitterIdStr =', req.query.twitterIdStr
    opts = twitterIdStr: req.query.twitterIdStr
    ModelFactory.create('illustrator').findById opts
    .then (illustrator) ->
      console.log 'IllustratorProvider.findById result = ', illustrator
      unless illustrator?
        res.status(400).send(null)
        return
      ModelFactory.create('pict').findByIllustratorObjectId postedBy: illustrator._id
    .then (data) ->
      console.log data
      console.log data.postedBy
      console.log data.pictTweetList.length
      res.send data
    .catch (err) ->
      console.error 'app.get /api/collect/picts/ error ', err
      res.status(400).send(err)

  app.get '/api/collect/:skip?/:limit?', (req, res) ->
    opts =
      skip: req.params.skip - 0
      limit: req.params.limit - 0
    ModelFactory.create('pict').find opts
    .then (data) -> res.send data

  app.post '/api/collect/profile', (req, res) ->
    pictCollection = new PictCollection(req.session.passport.user, req.body.twitterIdStr)
    pictCollection.getIllustratorTwitterProfile()
    .then (data) -> pictCollection.setIllustratorRawData(data)
    .then -> pictCollection.getIllustratorRawData()
    .then (illustratorRawData) -> pictCollection.setUserTimelineMaxId(illustratorRawData.status.id_str)
    .then -> pictCollection.normalizeIllustratorData()
    .then -> pictCollection.updateIllustratorData()
    .then (data) -> pictCollection.setIllustratorDBData(data)
    .then (data) -> res.send data
    .catch (err) -> console.log err
