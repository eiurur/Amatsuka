dir         = './lib/'
async       = require 'async'
{serve}     = require './app/serve'
{startTask} =　require "#{dir}collect/start-task"
{settings}  = if process.env.NODE_ENV is "production"
  require "#{dir}configs/production"
else
  require "#{dir}configs/development"

tasks4startUp = [

  (callback) ->

    # Start Server
    console.log "■ Server task start"
    serve null, "Create Server"
    setTimeout (-> callback(null, "Serve\n")), settings.GRACE_TIME_SERVER
    return

  # , (callback) ->

  #   # Cron Server
  #   my.c "■ Cron task start"
  #   startTask null, "Cron"
  #   setTimeout (-> callback(null, "Cron\n")), settings.GRACE_TIME_SERVER
  #   return

]

async.series tasks4startUp, (err, results) ->
  if err then console.error err else console.log "\nall done... Start!!!!\n"
  return
