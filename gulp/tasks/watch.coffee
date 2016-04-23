gulp   = require("gulp")
watch  = require("gulp-watch")
config = require("../config").watch

gulp.task "watch", ->

  watch config.coffee, ->
    gulp.start ["coffee"]

  watch config.coffee_app_public, ->
    gulp.start ["coffee_app_public"]

  watch config.sass, ->
    gulp.start ["sass"]

  watch config.jade_copy, ->
    gulp.start ["jade_copy"]

  watch config.images_copy, ->
    gulp.start ["images_copy"]
