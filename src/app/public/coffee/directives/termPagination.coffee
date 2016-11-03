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
            ng-click="$ctrl.paginate(1)"><</a>
        </div>
        <a class="pagination__term--active">{{$ctrl.date}}   【{{$ctrl.total}}】</a>
        <div class="pagination__button">
          <a class="pagination__term--next" ng-click="$ctrl.paginate(-1)">></a>
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
    @bindKeyAction()
    @$scope.$on '$destroy', => @unbindKeyAction()

  bindKeyAction: ->
    Mousetrap.bind ['ctrl+left'], => @paginate(-1)
    Mousetrap.bind ['ctrl+right'], => @paginate(1)

  unbindKeyAction: ->
    Mousetrap.unbind ['ctrl+left', 'ctrl+right']

  paginate: (amount) ->
    @date = @TimeService.changeDate('days', @date, amount)
    @TermPeginateDataServicve.publish(date: @date)
    @$scope.$emit 'termPagination::paginate', date: @date

TermPaginationController.$inject = ['$scope', 'TimeService', 'TermPeginateDataServicve', 'URLParameterChecker']