# angular.module "myApp.directives"
#   .directive 'tweetListContainer', ->
#     restrict: 'E'
#     scope: {}
#     template: """
#       <dot-loader ng-if="!$ctrl.tweets.items" class="user-sidebar__contents--box-loading-init"></dot-loader>
#       <div ng-if="$ctrl.message" class="list__status--message text-center">{{message}}
#       </div>

#       <span ng-if="$ctrl.layoutType == 'grid'">
#         <div infinite-scroll="$ctrl.tweets.nextPage()" infinite-scroll-distance="2" infinite-scroll-disabled="$ctrl.tweets.busy" masonry="masonry" preserve-order="preserve-order" class="timeline timeline--grid">
#           <div ng-repeat="tweet in $ctrl.tweets.items" class="masonry-brick timeline__post timeline__post--grid">
#             <grid-layout-tweet tweet="tweet" listIdStr="$ctrl.listIdStr"></grid-layout-tweet>
#           </div>
#         </div>

#         <div class="loading-bar loading-bar--grid">
#           <dot-loader ng-if="$ctrl.tweets.busy" class="box-loading-padding-vertical">
#           </dot-loader>
#           <div ng-show="$ctrl.tweets.isLast" class="text-center">終わりです</div>
#         </div>
#       </span>

#       <span ng-if="$ctrl.layoutType == 'list'">
#         <div infinite-scroll="$ctrl.tweets.nextPage()" infinite-scroll-distance="2" infinite-scroll-disabled="$ctrl.tweets.busy" class="timeline timeline--list">
#           <div ng-repeat="tweet in $ctrl.tweets.items" class="timeline__post">
#             <list-layout-tweet tweet="tweet"></list-layout-tweet>
#           </div>

#           <div class="loading-bar">
#             <dot-loader ng-if="$ctrl.tweets.busy" class="box-loading-padding-vertical">
#             </dot-loader>
#             <div ng-show="$ctrl.tweets.isLast" class="text-center">終わりです</div>
#           </div>
#         </div>
#       </span>

#     """
#     bindToController: {}
#     controllerAs: "$ctrl"
#     controller: TweetListController

# class TweetListController
#   constructor: (@$location, @$scope, @AuthService, @ListService, @Tweets, @TweetService) ->
#     @isLoaded   = false
#     @layoutType = 'grid'

#     # 共通の処理
#     # AmatsukaList や AmatsukaFollowList の生成処理は /index で行うことにした。
#     @ListService.amatsukaList =
#       data: JSON.parse(localStorage.getItem 'amatsukaList') || {}
#       member: JSON.parse(localStorage.getItem 'amatsukaFollowList') || []

#     unless @ListService.hasListData() then @$location.path '/'

#     @tweets = new @Tweets([], undefined, 'fav', @AuthService.user._json.id_str)
#     @listIdStr = ListService.amatsukaList.data.id_str
#     @isLoaded  = true
#     do @subscribe

#   subscribe: ->
#     @$scope.$on 'addMember', (event, args) =>
#       @TweetService.applyFollowStatusChange @tweets.items, args

#     @$scope.$on 'resize::resize', (event, args) =>
#       @$scope.$apply => @layoutType = args.layoutType

# TweetListController.$inject = ['$location', '$scope', 'AuthService', 'ListService', 'Tweets', 'TweetService']

