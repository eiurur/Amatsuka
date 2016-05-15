angular.module "myApp.directives"
  .directive 'maoContainer', ->
    restrict: 'E'
    scope: {}
    template: """
      <ul class="nav nav-pills nav-stacked col-md-1 col-sm-2">
        <li ng-repeat="tab in $ctrl.tabs" ng-class="{active: tab.active}">
          <a href="{{tab.href}}" data-toggle="tab" ng-click="$ctrl.select(tab.name)" >{{tab.name}}</a>
        </li>
      </ul>
      <div class="tab-content col-md-11 col-sm-10">
        <div id="tweets" class="tab-pane active">
          <mao-list-container></mao-list-container>
        </div>
        <div id="stats" class="tab-pane">
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
        "href": '#tweets'
        "name": 'Tweets'
        "active": true
      }
      {
        "href": '#stats'
        "name": 'Stats'
        "active": false
      }
    ]
    console.log @tabs

  select: (name) ->
    console.log name
    @tabs.forEach (tab) ->
      console.log tab.name
      console.log tab.name is name
      tab.active = if tab.name is name then true else false
      console.log tab