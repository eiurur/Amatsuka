const gulp = require('gulp');
gulp.task(
  'build',
  gulp.parallel(
    'bower_angularjs',
    'bower_js',
    'bower_css',
    'bower_font',
    'coffee',
    'coffee_app_public',
    'sass',
    'pug',
    'images_copy',
  ),
);
