gulp   = require 'gulp'
sass   = require 'gulp-sass'
$      = do require 'gulp-load-plugins'
config = require('../config').sass

# SASS (src/scss)
gulp.task "sass", ->
  gulp.src config.src
    .pipe $.plumber()
    .pipe sass
      outputStyle: "expanded"
    .pipe gulp.dest config.dest
    .pipe $.rename suffix: '.min'
    .pipe $.cssmin()
    .pipe gulp.dest config.dest
    .pipe $.gzip()
    .pipe gulp.dest config.dest
    .pipe $.notify 'CSS task complete'
