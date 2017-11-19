module.exports = (app) ->

  app.get '/logout', (req, res) ->
    return unless req.session?.id?
    req.logout()
    req.session.destroy()
    res.redirect "/"
    return

  app.get '/isAuthenticated', (req, res) ->
    session = req.session.passport
    if !req.session.passport && typeof req.session.passport.user is "undefined"
      res.status(401).send("have not session")
      return
    res.send session.user
    return

  # serve index and view partials
  app.get '/', (req, res) ->
    res.render "index"
    return

  app.get '/partials/:name', (req, res) ->
    name = req.params.name
    res.render "partials/" + name
    return

  # redirect all others to the index (HTML5 history)
  app.get '*', (req, res) ->
    res.render "index"
    return
