angular.module "myApp.controllers"
  .controller "ListCtrl", (
    $scope
    AuthService
    TweetService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user
  console.log 'List AuthService.user = ', AuthService.user



  # Listをsy富戸kする
  TweetService.getListsList()
  .then (data) ->
    $scope.lists = data.data

  .then (data)


  # Listwo上部に並べる

  # そのListのツイートを取得する(とりあえずAmatsukaが初期)

    # あてゃIndexCtrlと同じ漢字

  # $on -> Listが切り替わったら

    # そのListのついーとを取得する

    # 後は同じ




