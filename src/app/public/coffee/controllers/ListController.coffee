angular.module "myApp.controllers"
  .controller "ListCtrl", (
    $scope
    AuthService
    TweetService
    Tweets
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'

  # [WIP]

  # Listを取得する
  # TweetService.getListsList()
  # .then (data) ->
  #   $scope.lists = data.data
  # .then (data)


  # Listを上部に並べる

  # そのListのツイートを取得する(とりあえずAmatsukaが初期)

  # $on -> Listが切り替わったら

    # そのListのついーとを取得する





