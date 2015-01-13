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

  # if _.isEmpty StreamService.filters
  #   $scope.rts = []
  #   $scope.tl = []
  #   $scope.images = []
  # else
  #   $scope.rts = StreamService.filters.rts
  #   $scope.tl = StreamService.filters.tl
  #   $scope.images = StreamService.filters.images

  # socket.on "tweet", (tweet) ->

  #   String.prototype.iconBigger = TweetService.iconBigger
  #   String.prototype.textLinkReplace = TweetService.textLinkReplace

  #   # user(monologe?)
  #   tempTweet =
  #     isRT: false
  #     user:
  #       icon: TweetService.get(tweet, 'profile_image_url', false).iconBigger()
  #       text: TweetService.get(tweet, 'text', false).textLinkReplace()
  #       name: TweetService.get(tweet, 'name', false)
  #       screenName: TweetService.get(tweet, 'screen_name', false)

  #   # RT
  #   if _.has tweet, 'retweeted_status'
  #     tempTweet.isRT = true
  #     tempRTTweet =
  #       rt:
  #         tweetIdStr: TweetService.get(tweet, 'tweet.id_str', true)
  #         icon: TweetService.get(tweet, 'profile_image_url', true).iconBigger()
  #         text: TweetService.get(tweet, 'text', true).textLinkReplace()
  #         name: TweetService.get(tweet, 'name', true)
  #         screenName: TweetService.get(tweet, 'screen_name', true)
  #     tempTweet = _.assign tempTweet, tempRTTweet

  #     # 同じRTが流れるのは煩わしい
  #     return if _.contains($scope.rts, tempRTTweet.rt.tweetIdStr)
  #     # rts.unshift tempRTTweet.rt.tweetIdStr
  #     unshift 'rts', tempRTTweet.rt.tweetIdStr


  #   # assign tweet
  #   if $scope.tl.length > 100
  #     pop 'tl'
  #     # $scope.tl.pop()
  #   # $scope.tl.unshift tempTweet
  #   unshift 'tl', tempTweet

  #   # assign image
  #   image =
  #     url: TweetService.get(tweet, 'media_url', tempTweet.isRT)
  #     text: TweetService.get(tweet, 'text', tempTweet.isRT).textLinkReplace()
  #     name: TweetService.get(tweet, 'name', tempTweet.isRT)
  #     screenName: TweetService.get(tweet, 'screen_name', tempTweet.isRT)
  #     icon: TweetService.get(
  #       tweet, 'profile_image_url', tempTweet.isRT
  #       ).iconBigger()
  #   return if _.isNull image.url
  #   pop 'images' if $scope.images.length > 50
  #   unshift 'images', image
  #   uniq 'images', 'url'


  # # LightBox
  # $scope.Lightbox = Lightbox
  # $scope.openLightboxModal = (index) ->
  #   Lightbox.openModal $scope.images, index