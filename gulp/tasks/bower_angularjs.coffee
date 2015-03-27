gulp   = require 'gulp'
bower  = require 'bower'
$      = do require 'gulp-load-plugins'
config = require('../config').bower_angularjs

gulp.task 'bower_angularjs', ->
  bower.commands.install().on 'end', (installed) ->
    gulp.src config.src
      .pipe $.plumber()
      .pipe $.concat('angular-lib.js')
      .pipe gulp.dest config.dest
      .pipe $.rename suffix: '.min'
      .pipe $.uglify mangle: false
      .pipe gulp.dest config.dest
      .pipe $.gzip()
      .pipe gulp.dest config.dest
      .pipe $.notify 'Library AngularJS task complete'
