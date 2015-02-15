angular.module "myApp.controllers"
  .controller "ConfigCtrl", (
    $scope
    AuthService
    TweetService
    ConfigService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user
  # $scope.displayFormats = ['list', 'grid']

  $scope.toggleDisplayFormat = ConfigService.toggleDisplayFormat

  # Listwo上部に並べる

  # そのListのツイートを取得する(とりあえずAmatsukaが初期)

    # あてゃIndexCtrlと同じ漢字

  # $on -> Listが切り替わったら

    # そのListのついーとを取得する

    # 後は同じ




