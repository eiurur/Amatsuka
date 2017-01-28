path = require 'path'
{my} = require path.resolve 'build', 'lib', 'my'

module.exports = (app) ->

  app.post '/api/download', (req, res) ->
    console.log "\n========> download, #{req.body.url}\n"
    my.loadBase64Data req.body.url
    .then (base64Data) ->
      console.log 'base64toBlob', base64Data.length
      res.send base64Data
