module.exports = (app) ->
  app.use '/api/ranking/?', (req, res, next) ->
    connectAllowedHost = if process.env.NODE_ENV is 'development' then 'https://127.0.0.1:9021' else 'https://kawpaa.eiurur.xyz'
    res.setHeader 'Access-Control-Allow-Origin', connectAllowedHost
    res.setHeader 'Access-Control-Allow-Methods', 'GET'
    res.setHeader 'Access-Control-Allow-Headers', 'X-Requested-With,content-type'
    res.setHeader 'Access-Control-Allow-Credentials', true
    next()