module.exports = (app) ->
  app.use (err, req, res, next) ->
    res.status err.status || 500
    res.send err