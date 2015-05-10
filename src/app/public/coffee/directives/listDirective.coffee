angular.module "myApp.directives"
  .directive 'copyMember', (toaster, TweetService) ->
    restrict: 'A'
    scope:
      sourceList: '='
    link: (scope, element, attrs) ->
      element.on 'click', (event) ->
        if window.confirm('コピーしてもよろしいですか？')
          toaster.pop 'wait', "Now Copying ...", '', 0, 'trustedHtml'

          scope.sourceList.copyMember2AmatsukaList()
          .then (data) ->
            toaster.clear()

            # コピー終了を通知
            toaster.pop 'success', "Finished copy member", '', 2000, 'trustedHtml'