angular.module "myApp.directives"
  .directive 'userProfile', ->
    restrict: 'E'
    scope: {}
    template: """
      <div class="drawer__header">
        <div ng-if="$ctrl.user.screen_name" class="media drawer__controll">
          <a href="https://www.twitter.com/{{::$ctrl.user.screen_name}}" target="_blank" class="pull-left">
            <img ng-src="{{::$ctrl.user.profile_image_url_https}}" img-preload="img-preload" class="drawer__profile__icon fade"/>
          </a>
          <div class="media-body drawer__profile__body">
            <h4 class="media-heading drawer__profile__names">
              <span class="drawer__profile__names--name">{{::$ctrl.user.name}}</span>
              <span class="screen-name">@{{::$ctrl.user.screen_name}}</span>
            </h4>
            <span class="btn-wrapper"></span>
            <a followable="followable" follow-status="$ctrl.user.followStatus" list-id-str="{{listIdStr}}" twitter-id-str="{{::$ctrl.user.id_str}}" ng-disabled="isProcessing" class="btn btn-sm drawer__btn-follow"></a>
            <a href="/extract/@{{::$ctrl.user.screen_name}}" target="_blank" class="btn btn-sm drawer__icon-all-view">
              <i class="fa fa-external-link-square i__center-padding"></i>
            </a>
            <user-action-button-dropdowns user="$ctrl.user"></user-action-button-dropdowns>
          </div>
        </div>
      </div>
    """
    bindToController:
      user: "="
    controllerAs: "$ctrl"
    controller: UserProfileController

class UserProfileController
  constructor: () ->
    @isScrolledToBottom = false
    @prevTop = 0
    scrollableElement = angular.element(document).find('#scroll')
    scrollableElement.on 'scroll', _.throttle(@onScroll, 500)

  onScroll: (e) ->
    currentTop = angular.element(document).find('#scroll').scrollTop()
    controlElem = angular.element(document).find('.drawer__controll')

    if currentTop < @prevTop then controlElem.removeClass('drawer__controll--hide')
    else controlElem.addClass('drawer__controll--hide')
    @prevTop = currentTop

    # FIXME: なぜか動かない。FXXX
    # @isScrolledToBottom = currentTop < @prevTop
    # @prevTop = currentTop

UserProfileController.$inject = []
