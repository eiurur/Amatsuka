gulp = require 'gulp'
gulp.task 'build', [
  'bower_angularjs'
  'bower_js'
  'bower_css'
  'bower_font'
  'coffee'
  'coffee_app_public'
  'sass'
  'jade_copy'
  'images_copy'
]