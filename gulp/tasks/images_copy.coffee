gulp   = require 'gulp'
$      = do require 'gulp-load-plugins'
config = require('../config').images_copy

# images copy
gulp.task 'images_copy', ->
  gulp.src config.src
    .pipe $.plumber()
    .pipe $.changed(config.dest)
    .pipe $.imagemin()
    .pipe gulp.dest config.dest
    .pipe $.notify 'images task complete'