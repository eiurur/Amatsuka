angular.module "myApp.controllers"
  .controller "IndexCtrl", (
    $scope
    $log
    AuthService
    TweetService
    ) ->
  return if _.isEmpty AuthService.user

  pop = (prop) ->
    $scope[prop].pop()
    # StreamService.filters[prop].pop()

  unshift = (prop, val) ->
    $scope[prop].unshift(val)
    # StreamService.filters[prop].unshift(val)

  uniq = (prop, key) ->
    $scope[prop] = _.uniq $scope[prop], key

  $scope.favs = null
  # 動作テスト用
  console.log 'Index AuthService.user = ', AuthService.user

  TweetService.twitterPostTest(AuthService.user)
  .then (data) ->
    $scope.favs = data.data
    $scope.$apply()

  return
  # $scope.favs = _.filter $scope.favs,

  # # LightBox
  # $scope.Lightbox = Lightbox
  # $scope.openLightboxModal = (index) ->
  #   Lightbox.openModal $scope.images, index