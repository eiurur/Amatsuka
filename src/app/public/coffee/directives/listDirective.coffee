angular.module "myApp.directives"
  .directive 'copyMember', (TweetService) ->
    restrict: 'A'
    scope:
      sourceList: '='
    link: (scope, element, attrs) ->
      element.on 'click', (event) ->
        if window.confirm('コピーしてもよろしいですか？')
          scope.sourceList.copyMember2AmatsukaList()