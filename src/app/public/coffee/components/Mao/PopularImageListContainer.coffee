popularImageListContainerController = (TweetService) ->
  @$onInit = () =>
    opts =
      twitterIdStr: @twitterIdStr
      limit: 3
    TweetService.getPopularTweet opts
    .then (response) =>
      console.log response
      @tweets = response.data.pictTweetList[0..2]
  return # これが絶対必要

popularImageListContainerController.$inject = ['TweetService']

angular.module "myApp.directives"
  .component('popularImageListContainer', {
    bindings: 
      twitterIdStr: "<"
    template: """
      <section class="popular-tweets row">
        <div class="col-md-4 col-sm-4 col-xs-4" ng-repeat="tweet in $ctrl.tweets">
          <div class="popular-tweet">
            <img ng-src="{{::tweet.mediaUrl}}:small" data-img-src="{{::tweet.mediaUrl}}:small" tweet-id-str="{{::tweet.tweetIdStr}}" show-statuses="show-statuses" img-preload class="fade popular-tweets__img">
          </div>
        </div>
      </section>
    """
    controller: popularImageListContainerController
  })

