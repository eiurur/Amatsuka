angular.module "myApp.directives"
  .directive 'maoListContainer', ->
    restrict: 'E'
    scope: {}
    template: """
      <dot-loader ng-if="!$ctrl.tweetList.items" class="user-sidebar__contents--box-loading-init">
      </dot-loader>
      <div ng-if="$ctrl.tweetList.isAuthenticatedWithMao">
        <div infinite-scroll="$ctrl.tweetList.load()" infinite-scroll-distance="0" class="row-eq-height">
          <div style="padding: 15px;" ng-repeat="item in $ctrl.tweetList.items" class="col-lg-4 col-md-6 col-sm-6">
            <mao-tweet-article item="item"></mao-tweet-article>
          </div>
        </div>
        <div class="col-sm-12">
          <dot-loader ng-if="$ctrl.tweetList.busy" class="find--infinitescroll-content">
          </dot-loader>
          <div ng-show="$ctrl.tweetList.isLast" class="text-center find--infinitescroll-content find--infinitescroll-message">終わりです
          </div>
        </div>
      </div>
      <div ng-if="!$ctrl.tweetList.isAuthenticatedWithMao" class="col-sm-12">
        <div class="find--infinitescroll-message">
          <p>MaoでのTwitter認証がされていないのでこの機能は利用できません。</p>
          <p>MaoはAmatsukaのメンバーの人気の画像を毎日収集し、閲覧できる機能です。</p>
          <p>認証は以下のリンク先で行えます</p>
          <p>
            <a href="https://ma0.herokuapp.com" target="_blank" class="mao__link">
              Mao
              <i class="fa fa-external-link"></i>
            </a>
          </p>
        </div>
      </div>
    """
    bindToController: {}
    controllerAs: "$ctrl"
    controller: MaoListContoller

class MaoListContoller
  constructor: (@$location, @Mao, @ListService) ->

    # 共通の処理
    # AmatsukaList や AmatsukaFollowList の生成処理は /index で行うことにした。
    @ListService.amatsukaList =
      data: JSON.parse(localStorage.getItem 'amatsukaList') || {}
      member: JSON.parse(localStorage.getItem 'amatsukaFollowList') || []

    unless @ListService.hasListData() then @$location.path '/'

    date = moment().add(-1, 'days').format('YYYY-MM-DD')
    @tweetList = new @Mao(date)

  # subscribe: ->
  #   @$scope.$on 'MaoStatusController::publish', (event, args) => @date = args.date

MaoListContoller.$inject = ['$location', 'Mao', 'ListService']