angular.module "myApp.directives"
  .directive 'userProfile', ->
    restrict: 'E'
    scope: {}
    template: """
      <div class="user-sidebar__header">
        <div ng-if="$ctrl.user.screen_name" class="media user-sidebar__controll">
          <a href="https://www.twitter.com/{{::$ctrl.user.screen_name}}" target="_blank" class="pull-left">
            <img ng-src="{{::$ctrl.user.profile_image_url_https}}" img-preload="img-preload" class="user-sidebar__profile__icon fade"/>
          </a>
          <div class="media-body user-sidebar__profile__body">
            <h4 class="media-heading user-sidebar__profile__names">
              <span class="user-sidebar__profile__names--name">{{::$ctrl.user.name}}</span>
              <span class="screen-name">@{{::$ctrl.user.screen_name}}</span>
            </h4>
            <span class="btn-wrapper"></span>
            <a followable="followable" follow-status="$ctrl.user.followStatus" list-id-str="{{listIdStr}}" twitter-id-str="{{::$ctrl.user.id_str}}" ng-disabled="isProcessing" class="btn btn-sm user-sidebar__btn-follow"></a>
            <a href="/extract/@{{::$ctrl.user.screen_name}}" target="_blank" class="btn btn-sm user-sidebar__icon-all-view">
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
    controlElem = angular.element(document).find('.user-sidebar__controll')

    if currentTop < @prevTop then controlElem.removeClass('user-sidebar__controll--hide')
    else controlElem.addClass('user-sidebar__controll--hide')
    @prevTop = currentTop

    # FIXME: なぜか動かない。FXXX
    # @isScrolledToBottom = currentTop < @prevTop
    # @prevTop = currentTop

UserProfileController.$inject = []
