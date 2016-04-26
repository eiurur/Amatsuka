angular.module "myApp.directives"
  .directive 'maoTweetArticle', ->
    restrict: 'E'
    scope: {}
    template: """
      <div class="media find__media">
        <a twitter-id-str="{{::$ctrl.item.user.id_str}}" show-tweet="show-tweet" class="pull-left">
          <img ng-src="{{::$ctrl.item.user.profile_image_url_https}}" img-preload="img-preload" class="media-object thumbnail-img fade"/>
        </a>
        <div class="media-body">
          <h4 class="media-heading"><span class="name">{{::$ctrl.item.user.name}}</span><span class="screen-name">@{{::$ctrl.item.user.screen_name}}</span>
          </h4><a href="{{::$ctrl.item.user.url}}" target="_blank" class="link">{{::$ctrl.item.user.url}}</a>
        </div>
      </div>
      <div class="find__pict-tweet--container">
        <div class="row">
          <div ng-repeat="pict in $ctrl.item.pictList | limitTo: 12" class="col-lg-6 col-md-4 col-sm-6 col-xs-6">
            <div style="background-image: url('{{::pict.media.media_url_https}}:small')" zoom-image="zoom-image" data-img-src="{{::pict.media.media_url_https}}:orig" tweet-id-str="{{::pict.tweet.id_str}}" show-statuses="show-statuses" class="find__pict-tweet--img">
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