angular.module "myApp.controllers"
  .controller "IndexCtrl", (
    $scope
    $rootScope
    $log
    AuthService
    TweetService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user
  console.log 'Index AuthService.user = ', AuthService.user


  maxId = maxId || 0
  amatsukaList = {}

  # TweetService.twitterPostTest(AuthService.user)
  # .then (data) ->
  #   $scope.favs = data.data
  #   TweetService.getListsList(AuthService.user)
  # .then (data) ->
  #   $scope.lists = data.data
  #   $scope.$apply()

  # 動くけど次を読み込まない
  # TweetService.getListsList()
  # .then (data) ->

  #   amatsukaList = _.findWhere data.data, 'name': 'Amatsuka'
  # TweetService.getListsStatuses(listIdStr: amatsukaList.id_str, maxId: maxId)

  # .then (data) ->

  #   maxId = _.last(data.data).id_str
  #   $scope.tweets = TweetService.filterIncludeImage data.data
  #   $scope.$apply()

  TweetService.getListsList()
  .then (data) ->

    amatsukaList = _.findWhere data.data, 'name': 'Amatsuka'

    $scope.tweets = new Tweets(amatsukaList, maxId)

    #TweetService.getListsStatuses(listIdStr: amatsukaList.id_str, maxId: maxId)

  # .then (data) ->

  #   maxId = _.last(data.data).id_str
  #   $scope.tweets = TweetService.filterIncludeImage data.data
  #   $scope.$apply()


  # # LightBox
  # $scope.Lightbox = Lightbox
  # $scope.openLightboxModal = (index) ->
  #   Lightbox.openModal $scope.images, index