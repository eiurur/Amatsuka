angular.module "myApp.directives"
  .directive 'maoContainer', ->
    restrict: 'E'
    scope: {}
    template: """
      <div class="col-md-12">
          <ul class="mao__calender-list stylish-scrollbar--vertical">
            <li ng-repeat="tab in $ctrl.tabs" ng-class="{active: tab.active}">
              <a data-toggle="tab" ng-click="$ctrl.onSelected(tab)" >{{tab.name}}</a>
            </li>
          </ul>
      </div>
      <div class="tab-content col-md-12">
        <div id="tweets" class="row tab-pane active">
          <mao-list-container></mao-list-container>
        </div>
      </div>
    """
    bindToController: {}
    controllerAs: "$ctrl"
    controller: MaoContainerController

class MaoContainerController
  constructor: (@$scope, @TermPeginateDataServicve, @$httpParamSerializer, @MaoService, @TimeService) ->
    @tabs = []
    @tabType = ""
    @fetchTabData()
    @subscribe()

  fetchTabData: ->
    targetDates = @TimeService.getDatesPerMonth()
    tasks = targetDates.map (date) =>
      qs = @$httpParamSerializer date: date
      @MaoService.countTweetByMaoTokenAndDate(qs)
    Promise.all tasks
    .then (responses) =>
      console.log responses
      @tabs = responses.map (response, i) =>
        href: "#{location.pathname}?date=#{targetDates[i]}"
        id: targetDates[i]
        name: "#{targetDates[i].substr(5)} (#{response.data.count})"
        active: false
      @tabs[0].active = true

  activateLink: (clickedTab) ->
    @tabType = clickedTab.id
    @tabs.map (tab) -> tab.active = if tab.id is clickedTab.id then true else false

  onSelected: (clickedTab) ->
    @activateLink clickedTab
    @$scope.$broadcast 'MaoContainerController::paginate', date: clickedTab.id

  subscribe: ->
    @$scope.$on 'termPagination::paginate', (event, args) =>
      @activateLink id: args.date

MaoContainerController.$inject = ['$scope', '$TermPeginateDataServicve', '$httpParamSerializer', 'MaoService', 'TimeService']

