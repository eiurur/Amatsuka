gulp = require("gulp")
watch = require("gulp-watch")
config = require("../config").watch
gulp.task "watch", ->

  # coffee
  watch config.coffee, ->
    gulp.start ["coffee"]

  # coffee
  watch config.coffee_app, ->
    gulp.start ["coffee_app"]

  # coffee
  watch config.coffee_app_public, ->
    gulp.start ["coffee_app_public"]

  # coffee
  watch config.coffee_app_routes, ->
    gulp.start ["coffee_app_routes"]

  # coffee
  watch config.coffee_lib, ->
    gulp.start ["coffee_lib"]

  # sass
  watch config.sass, ->
    gulp.start ["sass"]

  # jade
  watch config.jade_copy, ->
    gulp.start ["jade_copy"]

  # images_copy
  watch config.images_copy, ->
    gulp.start ["images_copy"]
