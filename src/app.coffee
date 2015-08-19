path     = require 'path'
async    = require 'async'
{serve}  = require path.resolve 'build', 'app', 'serve'
settings = if process.env.NODE_ENV is 'production'
  require path.resolve 'build', 'lib', 'configs', 'production'
else
  require path.resolve 'build', 'lib', 'configs', 'development'

tasks4startUp = [

  (callback) ->

    # Start Server
    console.log "■ Server task start"
    serve null, "Create Server"
    setTimeout (-> callback(null, "Serve\n")), settings.GRACE_TIME_SERVER
    return
]

async.series tasks4startUp, (err, results) ->
  if err then console.error err else console.log "\nall done... Start!!!!\n"
  return
