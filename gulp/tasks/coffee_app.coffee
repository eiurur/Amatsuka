gulp   = require 'gulp'
$      = do require 'gulp-load-plugins'
config = require('../config').coffee_app

# coffee_app (src)
gulp.task 'coffee_app', ->
  gulp.src config.src
    .pipe $.plumber()
    .pipe $.coffeelint()
    .pipe $.coffeelint.reporter()
    .pipe $.coffee()
    .pipe gulp.dest config.dest
    .pipe $.notify 'coffee_app task complete'