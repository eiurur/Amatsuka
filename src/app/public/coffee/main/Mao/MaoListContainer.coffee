angular.module "myApp.directives"
  .directive 'maoListContainer', ->
    restrict: 'E'
    scope: {}
    template: """
      <dot-loader ng-if="!$ctrl.tweetList.items" class="user-sidebar__contents--box-loading-init">
      </dot-loader>
      <div ng-if="$ctrl.tweetList.isAuthenticatedWithMao">

        <div class="col-sm-12">
          <term-pagination></term-pagination>
        </div>

        <div infinite-scroll="$ctrl.tweetList.load()" infinite-scroll-distance="0" class="col-sm-12 row-eq-height">
          <div ng-repeat="item in $ctrl.tweetList.items" class="col-lg-4 col-md-6 col-sm-6 mao__tweet__container">
            <mao-tweet-article item="item"></mao-tweet-article>
          </div>
        </div>

        <div class="col-sm-12">
          <dot-loader ng-if="$ctrl.tweetList.busy" class="infinitescroll-content">
          </dot-loader>
          <div ng-show="$ctrl.tweetList.isLast" class="text-center infinitescroll-content infinitescroll-message">終わりです
          </div>
        </div>

        <div class="col-sm-12 pagination__term__container--bottom">
          <term-pagination></term-pagination>
        </div>

      </div>
      <div ng-if="!$ctrl.tweetList.isAuthenticatedWithMao" class="col-sm-12">
        <div class="infinitescroll-message">
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
  constructor: (@$location, @$scope, @Mao, @ListService, URLParameterChecker, @TimeService) ->
    unless @ListService.hasListData() then @$location.path '/'


    urlParameterChecker = new URLParameterChecker()
    console.log urlParameterChecker

    if _.isEmpty(urlParameterChecker.queryParams)
      urlParameterChecker.queryParams.date = moment().format('YYYY-MM-DD')

    @date = moment(urlParameterChecker.queryParams.date).add(-1, 'days').format('YYYY-MM-DD')
    @tweetList = new @Mao(@date)
    @subscribe()
    # 今はいらん
    # @term = $routeParams.term

  getTweet: (newQueryParams) ->
    @date = @TimeService.normalizeDate 'days', newQueryParams.date
    console.log 'getTweet ', @date
    @tweetList = new @Mao(@date)
    @tweetList.load()

  subscribe: ->
    @$scope.$on 'MaoStatusController::publish', (event, args) => @date = args.date

    @$scope.$on 'termPagination::paginate', (event, args) =>
      console.log 'termPagination::paginate on', args
      @$location.search 'date', args.date
      @getTweet(args)
      return

MaoListContoller.$inject = ['$location', '$scope', 'Mao', 'ListService', 'URLParameterChecker', 'TimeService']

