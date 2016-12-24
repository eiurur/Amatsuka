path         = require 'path'
async        = require 'async'
{serve}      = require path.resolve 'build', 'app', 'serve'
{manageCron} = require path.resolve 'build', 'lib', 'manageCron'
{settings}   = require path.resolve 'build', 'lib', 'configs', 'settings'

tasks4startUp = [

  (callback) ->

    console.log "■ Server task start"
    serve null, "Create Server"
    setTimeout (-> callback(null, "Serve\n")), settings.GRACE_TIME_SERVER
    return

  , (callback) ->

    console.log "■ collect profile and picts task start"
    manageCron null, "setup cron"
    setTimeout (-> callback(null, "Done! collect task\n")), 0
    return

]

async.series tasks4startUp, (err, results) ->
  if err then console.error err else console.log "\nall done... Start!!!!\n"
  return
