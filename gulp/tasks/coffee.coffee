gulp   = require 'gulp'
$      = do require 'gulp-load-plugins'
config = require('../config').coffee

# coffee (src)
gulp.task 'coffee', ->
  gulp.src config.src
    .pipe $.plumber()
    .pipe $.coffeelint()
    .pipe $.coffeelint.reporter()
    .pipe $.coffee()
    .pipe gulp.dest config.dest
    .pipe $.notify 'coffee task complete'