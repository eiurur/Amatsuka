angular.module "myApp.directives"
  .directive 'gridLayoutTweet', ->
    restrict: 'E'
    scope: {}
    template: """
      <div class="timeline__post--header timeline__post--header--grid">
        <div class="timeline__post--header--info timeline__post--header--info--grid">
          <div class="timeline__post--header--link timeline__post--header--link--grid">
            <span twitter-id-str="{{::$ctrl.tweet.user.id_str}}" show-drawer="show-drawer" class="timeline__post--header--user timeline__post--header--user--grid clickable">{{::$ctrl.tweet.user.screen_name}}
            </span><span ng-if="$ctrl.tweet.retweeted_status" class="timeline__post--header--rt_icon timeline__post--header--rt_icon--grid"><i class="fa fa-retweet"></i></span><a twitter-id-str="{{::$ctrl.tweet.retweeted_status.user.id_str}}" show-drawer="show-drawer" class="timeline__post--header--rt_source timeline__post--header--rt_source--grid">{{::$ctrl.tweet.retweeted_status.user.screen_name}}
            </a>
            <followable ng-if="!$ctrl.tweet.followStatus" list-id-str="{{$ctrl.listIdStr}}" tweet="{{$ctrl.tweet}}" follow-status="$ctrl.tweet.followStatus">
            </followable>
          </div>
        </div>
        <div class="timeline__post--header--time"><a href="https://{{::$ctrl.tweet.sourceUrl}}" target="_blank">{{::$ctrl.tweet.time}}
          </a>
        </div>
      </div>
      <div class="timeline__post--icon timeline__post--icon--grid"><img ng-src="{{::$ctrl.tweet.user.profile_image_url_https}}" img-preload="img-preload" show-drawer="show-drawer" twitter-id-str="{{::$ctrl.tweet.user.id_str}}" class="fade"/>
      </div>
      <div ng-repeat="picUrl in $ctrl.tweet.picUrlList" class="timeline__post--image timeline__post--image--grid">
        <img ng-if="!$ctrl.tweet.video_url" ng-src="{{::picUrl}}" img-preload="img-preload" zoom-image="zoom-image" data-img-src="{{::picUrl}}" class="fade"/>
        <video ng-if="$ctrl.tweet.video_url" poster="{{::picUrl}}" controls="controls" muted="muted">
          <source ng-src="{{::$ctrl.tweet.video_url | trusted}}" type="video/mp4">
          </source>
        </video>
      </div>
      <div ng-if="!config.isShowOnlyImage" class="timeline__post__text__container">
        <div ng-if="!$ctrl.tweet.retweeted_status" ng-bind-html="$ctrl.tweet.text | newlines" class="timeline__post--text timeline__post--text--grid">
        </div>
        <div ng-if="$ctrl.tweet.retweeted_status" class="timeline__post--blockquote timeline__post--blockquote--grid">
          <p><a twitter-id-str="{{::$ctrl.tweet.retweeted_status.user.id_str}}" show-drawer="show-drawer">{{::$ctrl.tweet.retweeted_status.user.screen_name}}
            </a>
          </p>
          <blockquote>
            <div ng-bind-html="$ctrl.tweet.text | newlines" class="timeline__post--text">
            </div>
          </blockquote>
        </div>
      </div>
      <div class="timeline__post--footer timeline__post--footer--grid">
        <div class="timeline__post--footer--contents">
          <div class="timeline__post--footer--contents--controls">
            <i retweet-num="$ctrl.tweet.retweetNum" retweeted="$ctrl.tweet.retweeted" tweet-id-str="{{::$ctrl.tweet.tweetIdStr}}" retweetable="retweetable" class="fa fa-retweet icon-retweet">{{$ctrl.tweet.retweetNum}}</i>
            <i fav-num="$ctrl.tweet.favNum" favorited="$ctrl.tweet.favorited" tweet-id-str="{{::$ctrl.tweet.tweetIdStr}}" favoritable="favoritable" class="fa fa-heart icon-heart">{{$ctrl.tweet.favNum}}</i>
            <a>
              <i data-url="{{::$ctrl.tweet.picOrigUrlList}}" filename="{{::$ctrl.tweet.fileName}}" download-from-url="download-from-url" class="fa fa-download"></i>
            </a>
          </div>
        </div>
      </div>
    """
    bindToController:
      tweet: "="
      listIdStr: "="
    controllerAs: "$ctrl"
    controller: GridLayoutTweet

class GridLayoutTweet
  constructor: () ->
    console.log @