angular.module "myApp.directives"
  .directive 'popularImageListContainer', ->
    restrict: 'E'
    scope: {}
    template: """
      <section class="popular-tweets row">
        <div class="col-md-4 col-sm-4 col-xs-4" ng-repeat="tweet in $ctrl.tweets">
          <div class="popular-tweet">
            <img ng-src="{{::tweet.mediaUrl}}:small" data-img-src="{{::tweet.mediaUrl}}:small" tweet-id-str="{{::tweet.tweetIdStr}}" show-statuses="show-statuses" img-preload class="fade popular-tweets__img">
          </div>
        </div>
      </section>
    """
    bindToController:
      twitterIdStr: '='
    controllerAs: "$ctrl"
    controller: PopularImageListContainerController

class PopularImageListContainerController
  LIMIT: 3
  constructor: (@TweetService) ->
    console.log @twitterIdStr
    opts =
      twitterIdStr: @twitterIdStr
      limit: @LIMIT
    @TweetService.getPopularTweet opts
    .then (data) =>
      console.log data
      @tweets = data.pictTweetList[0..2]


PopularImageListContainerController.$inject = ['TweetService']