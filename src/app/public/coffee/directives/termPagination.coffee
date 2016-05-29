angular.module "myApp.directives"
  .directive 'termPagination', ->
    restrict: 'E'
    scope: {}
    template: """
      <div class="pagination__term">
        <div class="pagination__button">
          <a class="pagination__term--prev" ng-click="$ctrl.paginate(-1)"><</a>
        </div>
        <a class="pagination__term--active">{{$ctrl.date}}   【{{$ctrl.total}}】
        </a>
        <div class="pagination__button">
        <a class="pagination__term--next" ng-click="$ctrl.paginate(1)">></a>
        </div>
      </div>
    """
    bindToController:
      term: "="
      total: "="
    controller: TermPaginationController
    controllerAs: "$ctrl"

class TermPaginationController
  constructor: (@$scope, @TimeService, @TermPeginateDataServicve, URLParameterChecker) ->
    urlParameterChecker = new URLParameterChecker()
    console.log 'TermPaginationController ', urlParameterChecker.queryParams
    if _.isEmpty(urlParameterChecker.queryParams)
      urlParameterChecker.queryParams.date = moment().subtract(1, 'days').format('YYYY-MM-DD')
    @date = @TimeService.normalizeDate('days', urlParameterChecker.queryParams.date)

    @subscribe()
    @bindKeyAction()
    @$scope.$on '$destroy', => @unbindKeyAction()

  bindKeyAction: ->
    Mousetrap.bind ['ctrl+left'], => @paginate(-1)
    Mousetrap.bind ['ctrl+right'], => @paginate(1)

  unbindKeyAction: ->
    Mousetrap.unbind ['ctrl+left', 'ctrl+right']

  subscribe: ->
    @$scope.$on 'TermPeginateDataServicve::publish', (event, args) => @date = args.date

  paginate: (amount) ->
    @date = @TimeService.changeDate('days', @date, amount)
    @TermPeginateDataServicve.publish(date: @date)
    @$scope.$emit 'termPagination::paginate', date: @date

TermPaginationController.$inject = ['$scope', 'TimeService', 'TermPeginateDataServicve', 'URLParameterChecker']