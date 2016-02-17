gulp   = require 'gulp'
$      = do require 'gulp-load-plugins'
config = require('../config').videos_copy

# videos copy
gulp.task 'videos_copy', ->
  gulp.src config.src
    .pipe $.plumber()
    .pipe gulp.dest config.dest
    .pipe $.notify 'videos task complete'