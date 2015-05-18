path = require("path")
dest = "./build"
src = "./src"
lib = "/lib"
app = '/app'
app_public = '/app/public'
app_routes = '/app/routes'

#//
# path.relative(from, to)
#
# path.relative('/data/orandea/test/aaa', '/data/orandea/impl/bbb')
# returns
# '../../impl/bbb'
#
# gulp-watchの第一引数にはglobで監視対象のパスを指定するのですが、パスの先頭を./みたいに.から始めると正常に動作しません。
# それで./src/js/**みたいなパスをpath.relative()を使ってsrc/js/**に直す必要があります。
# これで監視対象以下でファイルの追加や削除があってもwatchしてくれるようになりました。
relativeSrcPath = path.relative(".", src)
module.exports =

  # 出力先の指定
  dest: dest

  coffee:
    src: src + "/*.coffee"
    dest: dest

  coffee_lib:
    src: src + lib + "/**/*.coffee"
    dest: dest + lib

  coffee_app:
    src: src + app + "/*.coffee"
    dest: dest + app

  coffee_app_public:
    src: src + app_public + "/**/*.coffee"
    dest: dest + app_public + "/js"

  coffee_app_routes:
    src: src + app_routes + "/**/*.coffee"
    dest: dest + app_routes

  # jade:
  #   src: src + '/**/!(_)*.jade'
  #   dest: dest + '/app/views/'

  jade_copy:
    src: src + app + "/views/**"
    dest: dest + app + '/views/'

  images_copy:
    src: src + app_public + "/images/**"
    dest: dest + app_public + '/images/'

  sass:
    src: [src + app_public + "/sass/**//!(_)*"] # ファイル名の先頭がアンスコはビルド対象外にする
    dest: dest + app_public + "/css/"

  bower_css:
    src: [
      'bower_components/font-awesome/css/font-awesome.min.css'
      'bower_components/bootstrap/dist/css/bootstrap.min.css'
      'bower_components/bootflat/css/bootflat.css'
      'bower_components/angular/angular-csp.css'
      'bower_components/angularjs-toaster/toaster.min.css'
      'bower_components/ng-tags-input/ng-tags-input.min.css'
      'bower_components/ng-tags-input/ng-tags-input.bootstrap.min.css'
    ]
    dest: dest + app_public + "/css/vendors/"

  bower_js:
    src: [
      'bower_components/moment/min/moment.min.js'
      'bower_components/lodash/dist/lodash.min.js'
      'bower_components/jquery/dist/jquery.min.js'
      'bower_components/bootstrap/dist/js/bootstrap.min.js'
      'bower_components/es6-promise/promise.min.js'
      'bower_components/imagesloaded/imagesloaded.pkgd.min.js'
      'bower_components/masonry/dist/masonry.pkgd.min.js'
      'bower_components/file-saver-js/FileSaver.min.js'
    ]
    dest: dest + app_public + "/js/vendors/"

  bower_angularjs:
    src: [
      'bower_components/angular/angular.min.js'
      'bower_components/angular-route/angular-route.min.js'
      'bower_components/angular-animate/angular-animate.min.js'
      'bower_components/angular-sanitize/angular-sanitize.min.js'
      'bower_components/angular-masonry/angular-masonry.js'
      'bower_components/angularjs-toaster/toaster.min.js'
      'bower_components/ng-tags-input/ng-tags-input.min.js'
    ]
    dest: dest + app_public + "/js/vendors/"

  bower_font:
    src: [
      'bower_components/font-awesome/fonts/*'
    ]
    dest: dest + app_public + '/css/fonts/'

  clean:
    target: './build'

  serve:
    # root: './build'
    dest: './build'

  watch:
    coffee: relativeSrcPath + "/*.coffee"
    coffee_app: relativeSrcPath + app + "/*.coffee"
    coffee_app_public: relativeSrcPath + app_public + "/**/*.coffee"
    coffee_app_routes: relativeSrcPath + app_routes + "/**/*.coffee"
    coffee_lib: relativeSrcPath + lib + "/**/*.coffee"
    sass: relativeSrcPath + app_public + "/sass/**"
    jade_copy: relativeSrcPath + app + "/views/**"
    images_copy: relativeSrcPath + app_public + "/images/**"