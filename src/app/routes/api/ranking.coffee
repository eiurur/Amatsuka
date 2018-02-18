path           = require 'path'
moment         = require 'moment'
PictCollection = require path.resolve 'build', 'lib', 'PictCollection'
ModelFactory   = require path.resolve 'build', 'model', 'ModelFactory'

module.exports = (app) ->

  # /api/ranking/total/week
  app.get '/api/ranking/:sort/:term', (req, res) ->
    unless ['retweet', 'like', 'fav', 'total', 'lustful'].includes(req.params.sort)
      res.status(401).send("ソートは 'retweet', 'like', 'fav', 'total', 'lustful' のいずれかを渡してください")
      return
    unless ['days', 'weeks', 'months'].includes(req.params.term)
      res.status(401).send("期間は 'days', 'weeks', 'months' のいずれかを渡してください")
      return
    skip = if isNaN(req.query.skip) then 0 else req.query.skip - 0
    limit = if isNaN(req.query.limit) or (req.query.limit - 0) > 100 then 20 else req.query.limit - 0
    normalizedSort = if req.params.sort is 'like' then 'fav' else req.params.sort
    sortType = {}
    sortType["#{normalizedSort}Num"] = -1
    sort = sortType
    term = req.params.term.slice(0, -1) # days -> day, weeks -> week, months -> month
    $gte = moment(req.query.date).startOf(term).toDate()
    $lt = moment(req.query.date).endOf(term).toDate()
    opts =
      skip: skip
      limit: limit
      sort: sort
      condition: [
        createdAt: $gte: $gte, $lt: $lt
      ]
    method = if req.params.sort is 'lustful' then 'findLustfully' else 'find' # HACK: 苦しい
    ModelFactory.create('ranking')[method] opts
    .then (data) -> res.send data
    