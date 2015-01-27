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

  console.log 'Index AuthService.user = ', AuthService.user
  TweetService.twitterTest(AuthService.user)

  # # LightBox
  # $scope.Lightbox = Lightbox
  # $scope.openLightboxModal = (index) ->
  #   Lightbox.openModal $scope.images, index