path           = require 'path'
moment         = require 'moment'
PictCollection = require path.resolve 'build', 'lib', 'PictCollection'
ModelFactory   = require path.resolve 'build', 'model', 'ModelFactory'

module.exports = (app) ->

  # /api/ranking/total/week
  app.get '/api/ranking/:sort/:term', (req, res) ->
    unless ['retweet', 'like', 'fav', 'total'].includes(req.params.sort)
      res.status(401).send("ソートは'retweet', 'like', 'fav', 'total'のいずれかを渡してください")
      return
    unless ['day', 'week', 'month'].includes(req.params.term)
      res.status(401).send("期間は'day', 'week', 'month'のいずれかを渡してください")
      return
    skip = if isNaN(req.query.skip) then 0 else req.query.skip - 0
    limit = if isNaN(req.query.limit) or (req.query.limit - 0) > 100 then 20 else req.query.limit - 0
    normalizedSort = if req.params.sort is 'like' then 'fav' else req.params.sort
    sortType = {}
    sortType["#{normalizedSort}Num"] = -1
    sort = sortType
    term = req.params.term
    $gte = moment(req.query.date).startOf(term).toDate()
    $lt = moment(req.query.date).endOf(term).toDate()
    opts =
      skip: skip
      limit: limit
      sort: sort
      condition: [
        createdAt: $gte: $gte, $lt: $lt
      ]
    ModelFactory.create('ranking').find opts
    .then (data) -> res.send data
    