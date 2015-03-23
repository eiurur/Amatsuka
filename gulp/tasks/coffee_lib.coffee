gulp   = require 'gulp'
$      = do require 'gulp-load-plugins'
config = require('../config').coffee_lib

# coffee (src)
gulp.task 'coffee_lib', ->
  gulp.src config.src
    .pipe $.plumber()
    .pipe $.coffeelint()
    .pipe $.coffeelint.reporter()
    .pipe $.coffee()
    .pipe $.gzip()
    .pipe gulp.dest config.dest
    .pipe $.notify 'coffee_lib task complete'