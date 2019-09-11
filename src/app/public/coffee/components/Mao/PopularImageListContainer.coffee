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
            <img 
              class="lozad fade popular-tweets__img" 
              data-src="{{::tweet.mediaUrl}}:small" 
              data-img-src="{{::tweet.mediaUrl}}:small" 
              tweet-id-str="{{::tweet.tweetIdStr}}" 
              show-statuses="show-statuses" 
              img-preload="img-preload">
          </div>
        </div>
      </section>
    """
    controller: popularImageListContainerController
  })

