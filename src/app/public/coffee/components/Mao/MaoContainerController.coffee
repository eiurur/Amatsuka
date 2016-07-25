angular.module "myApp.directives"
  .directive 'maoContainer', ->
    restrict: 'E'
    scope: {}
    template: """
      <div class="col-md-1 col-sm-2">
        <div class="row">
        <ul class="nav nav-pills nav-stacked col-md-12">
          <li ng-repeat="tab in $ctrl.tabs" ng-class="{active: tab.active}">
            <a href="{{tab.href}}" data-toggle="tab" ng-click="$ctrl.select(tab.id)" >{{tab.name}}</a>
          </li>
        </ul>
        </div>
      </div>
      <div class="tab-content col-md-11 col-sm-10">
        <div id="tweets" class="row tab-pane active" ng-if="$ctrl.tabType == 'tweets'">
          <mao-list-container></mao-list-container>
        </div>
        <div id="stats" class="row tab-pane" ng-if="$ctrl.tabType == 'stats'">
          <mao-ranking-post-number></mao-ranking-post-number>
        </div>
      </div>
    """
    bindToController: {}
    controllerAs: "$ctrl"
    controller: MaoContainerController

class MaoContainerController
  constructor: ->
    @tabs = [
      {
        'href': '#tweets'
        'id': 'tweets'
        'name': 'Tweets'
        'active': true
      }
      {
        'href': '#stats'
        'id': 'stats'
        'name': 'Stats'
        'active': false
      }
    ]
    console.log @tabs
    @tabType = @tabs[0].id

  select: (id) ->
    console.log name

    # 一時的な措置
    @tabType = id

    @tabs.forEach (tab) ->
      console.log tab.id
      console.log tab.id is id
      tab.active = if tab.id is id then true else false
      console.log tab