gulp   = require 'gulp'
$      = do require 'gulp-load-plugins'
config = require('../config').coffee_app_routes

# coffee_app_routes (src)
gulp.task 'coffee_app_routes', ->
  gulp.src config.src
    .pipe $.plumber()
    .pipe $.coffeelint()
    .pipe $.coffeelint.reporter()
    .pipe $.coffee()
    .pipe gulp.dest config.dest
    .pipe $.notify 'coffee_app_routes task complete'