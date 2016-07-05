gulp   = require 'gulp'
sass   = require 'gulp-ruby-sass'
$      = do require 'gulp-load-plugins'
config = require('../config').sass

# SASS (src/scss)
gulp.task "sass", ->
  gulp.src config.src
    .pipe $.plumber()
    .pipe $.cached('sass')
    .pipe sass
      style: "expanded"
      compass: true
    .pipe gulp.dest config.dest
    .pipe $.rename suffix: '.min'
    .pipe $.csscomb()
    .pipe $.cssmin()
    .pipe gulp.dest config.dest
    .pipe $.gzip()
    .pipe gulp.dest config.dest
    .pipe $.notify 'CSS task complete'
