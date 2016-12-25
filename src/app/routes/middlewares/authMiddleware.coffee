module.exports = (app) ->
  app.use '/api/?', (req, res, next) ->
    console.log "(@^^)/~~~ ======> #{req.originalUrl}"
    unless typeof req.session.passport.user is "undefined"
      next()
    else
      console.log '(#^.^#) invalid'
      res.redirect '/'