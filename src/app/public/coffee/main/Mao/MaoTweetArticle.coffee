angular.module "myApp.directives"
  .directive 'maoTweetArticle', ->
    restrict: 'E'
    scope: {}
    template: """
      <div class="media mao__user">
        <a twitter-id-str="{{::$ctrl.item.user.id_str}}" show-tweet="show-tweet" class="pull-left">
          <img ng-src="{{::$ctrl.item.user.profile_image_url_https}}" img-preload="img-preload" class="mao__user__icon fade"/>
        </a>
        <div class="media-body">
          <h4 class="media-heading">
            <span class="name">{{::$ctrl.item.user.name}}</span>
            <span twitter-id-str="{{::$ctrl.item.user.id_str}}" show-tweet class="screen-name clickable">@{{::$ctrl.item.user.screen_name}}</span>
          </h4>
        </div>
      </div>
      <div class="find__pict-tweet--container">
        <div>
          <div ng-repeat="pict in $ctrl.item.pictList | limitTo: 12" class="col-lg-6 col-md-4 col-sm-6 col-xs-6 mao__user__container">
            <div class="mao__pict__container">
              <img ng-src="{{::pict.media.media_url_https}}:small" data-img-src="{{::pict.media.media_url_https}}" tweet-id-str="{{::pict.tweet.id_str}}" show-statuses="show-statuses" img-preload class="fade find__pict-tweet--img">
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

# MaoTweetArticleController.$inject = ['ListService']