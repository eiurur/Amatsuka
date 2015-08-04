path    = require 'path'
gulp    = require 'gulp'
$       = do require 'gulp-load-plugins'
config  = require('../config').coffee_lib
optFile = path.resolve 'config.json'

# coffee (src)
gulp.task 'coffee_lib', ->
  gulp.src config.src
    .pipe $.plumber()
    .pipe $.coffeelint(optFile: optFile)
    .pipe $.coffeelint.reporter()
    .pipe $.coffee()
    .pipe gulp.dest config.dest
    .pipe $.notify 'coffee_lib task complete'