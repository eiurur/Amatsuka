angular.module "myApp.directives"
  .directive 'maoRankingPostNumber', ->
    restrict: 'E'
    scope: {}
    template: """
    <section infinite-scroll="$ctrl.tweetCountList.load()" infinite-scroll-distance="0" class="row fillbars">

      <div ng-repeat="item in $ctrl.tweetCountList.items" class="fillbar">

        <div class="col-md-3 col-sm-3 col-xs-6 fillbar__user">
          <img ng-src="{{item.postedBy.icon}}" twitter-id-str="{{item.postedBy.twitterIdStr}}" show-user-sidebar img-preload class="fade fillbar__icon">
          <span class="fillbar__screen-name clickable" twitter-id-str="{{item.postedBy.twitterIdStr}}"  show-user-sidebar>{{item.postedBy.screenName}}</span>
        </div>
        <div class="col-md-9 col-sm-9 col-xs-6">
          <div class="progress">
            <div class="progress-bar" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" ng-style="{ 'width': item.postCount / $ctrl.tweetCountList.maxCount * 100 + '%'}">
              <span class="fillbar__count">
                {{item.postCount}}
              </span>
            </div>
          </div>
        </div>
      </div>

      <div class="col-sm-12">
        <dot-loader ng-if="$ctrl.tweetCountList.busy" class="infinitescroll-content">
        </dot-loader>
        <div ng-show="$ctrl.tweetCountList.isLast" class="text-center infinitescroll-content infinitescroll-message">終わりです
        </div>
      </div>

    </section>
    """
    bindToController: {}
    controllerAs: "$ctrl"
    controller: MaoRankingPostNumber

class MaoRankingPostNumber
  constructor: (TweetCountList) ->
    @tweetCountList = new TweetCountList()

MaoRankingPostNumber.$inject = ['TweetCountList']
