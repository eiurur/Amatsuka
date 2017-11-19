angular.module "myApp.directives"
  .directive 'userActionButtonDropdowns', ->
    restrict: 'E'
    scope: {}
    template: """
      <div class="btn-group">
        <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          … <span class="caret"></span>
        </button>
        <ul class="dropdown-menu">
          <li><a href="#" ng-click="$ctrl.mute()">{{$ctrl.muteMenuText}}</a></li>
          <li><a href="#" ng-click="$ctrl.block()">{{$ctrl.blockMenuText}}</a></li>
        </ul>
      </div>
    """
    bindToController:
      user: "="
    controllerAs: "$ctrl"
    controller: UserActionButtonDropdownsController

class UserActionButtonDropdownsController
  constructor: (@$httpParamSerializer, @BlackUserListService, @TweetService) ->
    # console.log 'userActionButtonDropdowns', @user
    # console.log 'BlackUserListService.mutes = ', @BlackUserListService.mute.get()
    # console.log 'BlackUserListService.blocks = ', @BlackUserListService.block.get()
    console.log 'UserProfileController user = ', @

    @muteIdList = @BlackUserListService.mute.get()
    @blockIdList = @BlackUserListService.block.get()

    @setMute()
    @setBlock()

  setMute: (reversedMuteCondition) ->
    @isMuting = reversedMuteCondition || @muteIdList.includes(@user.id_str)
    @muteMenuText = if @isMuting then 'Mute解除' else 'Mute'

  setBlock: (reversedBlockCondition) ->
    @isBlocking = reversedBlockCondition || @blockIdList.includes(@user.id_str)
    @blockMenuText = if @isBlocking then 'Block解除' else 'Block'

  mute: ->
    opts =
      isMuting: @isMuting
      twitterIdStr: @user.id_str

    @setMute(!@isMuting)
    @muteIdList.push @user.id_str
    @BlackUserListService.mute.set(@muteIdList)

    @TweetService.mute(opts)
    .then (result) => console.log result

  block: ->
    opts =
      isBlocking: @isBlocking
      twitterIdStr: @user.id_str

    @setBlock(!@isBlocking)
    @blockIdList.push @user.id_str
    @BlackUserListService.block.set(@blockIdList)

    @TweetService.block(opts)
    .then (result) =>
      console.log result

UserActionButtonDropdownsController.$inject = ['$httpParamSerializer', 'BlackUserListService', 'TweetService']
