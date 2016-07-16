angular.module "myApp.directives"
  .directive 'maoTweetArticle', ->
    restrict: 'E'
    scope: {}
    template: """
      <div class="find__pict-tweet--container">
        <div>
          <div mao__user__container">
            <div class="mao__pict__container">
              <img ng-src="{{::$ctrl.item.media.media_url_https}}:small" data-img-src="{{::$ctrl.item.media.media_url_https}}" tweet-id-str="{{::$ctrl.item.tweet.id_str}}" show-statuses="show-statuses" img-preload class="fade find__pict-tweet--img">
            </div>
            <div class="media mao__user">
              <a twitter-id-str="{{::$ctrl.item.tweet.user.id_str}}" show-user-sidebar="show-user-sidebar">
                <img ng-src="{{::$ctrl.item.tweet.user.profile_image_url_https}}" img-preload="img-preload" class="mao__user__icon fade"/>
              </a>
              <div>
                <h4 class="media-heading">
                  <span twitter-id-str="{{::$ctrl.item.tweet.user.id_str}}" show-user-sidebar class="mao__user__screen-name screen-name clickable">@{{::$ctrl.item.tweet.user.screen_name}}</span>
                </h4>
              </div>
            </div>
          </div>
        </div>
      </div>
    """
    bindToController:
      item: '='
    controllerAs: "$ctrl"
    controller: MaoTweetArticleController

class MaoTweetArticleController
  constructor: ->
