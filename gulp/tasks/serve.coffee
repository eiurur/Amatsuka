gulp      = require 'gulp'
path      = require 'path'
node      = require 'node-dev'
$         = do require 'gulp-load-plugins'
webserver = require 'gulp-webserver'
config    = require('../config').serve

gulp.task "serve", ->
  serverPath = config.dest + '/app.js'
  node [serverPath]
  # setInterval (->), 1000

  # gulp.src config.dest
  #     .pipe webserver
  #       host: '127.0.0.1'
  #       port: 4321
  #       livereload: true
  #       open: true


