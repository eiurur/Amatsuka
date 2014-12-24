gulp   = require 'gulp'
$      = do require 'gulp-load-plugins'
config = require('../config').jade_copy

# jade copy
gulp.task 'jade_copy', ->
  gulp.src config.src
    .pipe $.plumber()
    .pipe gulp.dest config.dest
    .pipe $.notify 'jade_copy task complete'