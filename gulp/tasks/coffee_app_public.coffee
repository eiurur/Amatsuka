gulp       = require 'gulp'
$          = do require 'gulp-load-plugins'
ngAnnotate = require 'gulp-ng-annotate'
config     = require('../config').coffee_app_public

gulp.task 'coffee_app_public', ->
  gulp.src config.src
    .pipe $.plumber()
    .pipe $.coffeelint()
    .pipe $.coffeelint.reporter()
    .pipe $.coffee(bare: true)
    .pipe $.concat('main.js')
    .pipe ngAnnotate()
    .pipe gulp.dest config.dest
    .pipe $.stripDebug()
    .pipe $.rename suffix: '.min'
    .pipe $.uglify mangle: false
    .pipe gulp.dest config.dest
    .pipe $.notify 'coffee_app_public task complete'
