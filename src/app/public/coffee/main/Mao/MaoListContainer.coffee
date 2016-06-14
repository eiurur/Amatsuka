angular.module "myApp.directives"
  .directive 'maoListContainer', ->
    restrict: 'E'
    scope: {}
    template: """
      <dot-loader ng-if="!$ctrl.tweetList.items" class="user-sidebar__contents--box-loading-init">
      </dot-loader>
      <div ng-if="$ctrl.tweetList.isAuthenticatedWithMao">

        <div class="col-sm-12">
          <term-pagination total="$ctrl.tweetTotalNumber"></term-pagination>
        </div>

        <div infinite-scroll="$ctrl.tweetList.load()" infinite-scroll-distance="0">
          <div ng-repeat="item in $ctrl.tweetList.items" class="col-lg-2 col-md-3 col-sm-4 col-xs-6 mao__tweet__container">
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
          <term-pagination total="$ctrl.tweetTotalNumber"></term-pagination>
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
          <div class="mao__description__division"></div>
          <div class="mao__description__image">
          </div>
        </div>
      </div>
    """
    bindToController: {}
    controllerAs: "$ctrl"
    controller: MaoListContoller

class MaoListContoller
  constructor: (@$location, @$httpParamSerializer, @$scope, @Mao, @MaoService, URLParameterChecker, @TimeService) ->
    urlParameterChecker = new URLParameterChecker()
    console.log urlParameterChecker

    if _.isEmpty(urlParameterChecker.queryParams)
      urlParameterChecker.queryParams.date = moment().add(-1, 'days').format('YYYY-MM-DD')

    @date = moment(urlParameterChecker.queryParams.date).format('YYYY-MM-DD')
    @tweetList = new @Mao(@date)

    @tweetTotalNumber = 0
    qs = @$httpParamSerializer date: @date
    @MaoService.countTweetByMaoTokenAndDate(qs)
    .then (response) =>
      @tweetTotalNumber = response.data.count

    @subscribe()
    # 今はいらん
    # @term = $routeParams.term

  getTweet: (newQueryParams) ->
    @date = @TimeService.normalizeDate 'days', newQueryParams.date
    @tweetList = new @Mao(@date)
    @tweetList.load()
    console.log 'getTweet ', @date

  subscribe: ->
    @$scope.$on 'MaoStatusController::publish', (event, args) => @date = args.date

    @$scope.$on 'termPagination::paginate', (event, args) =>
      console.log 'termPagination::paginate on', args
      @$location.search 'date', args.date
      @getTweet(args)
      return

MaoListContoller.$inject = ['$location', '$httpParamSerializer', '$scope', 'Mao', 'MaoService', 'URLParameterChecker', 'TimeService']

