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
    src: [
      src + "/**/*.coffee"
      "!" + src + app_public + "/**/*.coffee"
    ]
    dest: dest

  coffee_app_public:
    src: src + app_public + "/**/*.coffee"
    dest: dest + app_public + "/js"

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
      'bower_components/font-awesome/css/font-awesome.css'
      'bower_components/bootstrap/dist/css/bootstrap.css'
      'bower_components/angular/angular-csp.css'
      'bower_components/angularjs-toaster/toaster.css'
      'bower_components/ng-tags-input/ng-tags-input.css'
      'bower_components/ng-tags-input/ng-tags-input.bootstrap.css'
    ]
    dest: dest + app_public + "/css/vendors/"

  bower_js:
    src: [
      'bower_components/moment/moment.js'
      'bower_components/lodash/dist/lodash.js'
      'bower_components/jquery/dist/jquery.js'
      'bower_components/bootstrap/dist/js/bootstrap.js'
      'bower_components/imagesloaded/imagesloaded.pkgd.js'
      'bower_components/masonry/dist/masonry.pkgd.js'
      'bower_components/file-saver-js/FileSaver.js'
      'bower_components/mousetrap/mousetrap.js'
    ]
    dest: dest + app_public + "/js/vendors/"

  bower_angularjs:
    src: [
      'bower_components/angular/angular.js'
      'bower_components/angular-route/angular-route.js'
      'bower_components/angular-animate/angular-animate.js'
      'bower_components/angular-sanitize/angular-sanitize.js'
      'bower_components/angular-touch/angular-touch.js'
      'bower_components/nginfinitescroll/build/ng-infinite-scroll.js'
      'bower_components/angular-masonry/angular-masonry.js'
      'bower_components/angularjs-toaster/toaster.js'
      'bower_components/ng-tags-input/ng-tags-input.js'
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
    coffee: [
      relativeSrcPath + "/**/*.coffee"
      "!" + relativeSrcPath + app_public + "/**/*.coffee"
    ]
    coffee_app_public: relativeSrcPath + app_public + "/**/*.coffee"
    sass: relativeSrcPath + app_public + "/sass/**"
    jade_copy: relativeSrcPath + app + "/views/**"
    images_copy: relativeSrcPath + app_public + "/images/**"
