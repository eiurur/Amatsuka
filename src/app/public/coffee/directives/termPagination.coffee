angular.module "myApp.directives"
  .directive 'termPagination', ->
    restrict: 'E'
    scope: {}
    template: """
      <div class="pagination__term">
        <div class="pagination__button">
          <a
            class="pagination__term--prev"
            scroll-on-click="scroll-on-click" scroll-to="body"
            ng-click="$ctrl.paginate($ctrl.NEXT)"><</a>
        </div>
        <a class="pagination__term--active">{{$ctrl.date}}   【{{$ctrl.total}}】</a>
        <div class="pagination__button">
          <a class="pagination__term--next" ng-click="$ctrl.paginate($ctrl.PREV)">></a>
        </div>
      </div>
    """
    bindToController:
      date: "="
      term: "="
      total: "="
    controller: TermPaginationController
    controllerAs: "$ctrl"

class TermPaginationController
  constructor: (@$scope, @TimeService, @TermPeginateDataServicve, URLParameterChecker) ->
    @NEXT = 1
    @PREV = -1
    @bindKeyAction()
    @$scope.$on '$destroy', => @unbindKeyAction()

  bindKeyAction: ->
    Mousetrap.bind ['ctrl+left'], => @paginate(@NEXT)
    Mousetrap.bind ['ctrl+right'], => @paginate(@PREV)

  unbindKeyAction: ->
    Mousetrap.unbind ['ctrl+left', 'ctrl+right']

  paginate: (amount) ->
    @date = @TimeService.changeDate('days', @date, amount)
    @TermPeginateDataServicve.publish(date: @date)
    @$scope.$emit 'termPagination::paginate', date: @date

TermPaginationController.$inject = ['$scope', 'TimeService', 'TermPeginateDataServicve', 'URLParameterChecker']