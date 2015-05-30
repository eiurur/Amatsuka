angular.module "myApp.directives"
  .directive 'copyMember', ($rootScope, toaster, TweetService) ->
    restrict: 'A'
    scope:
      sourceList: '='
    link: (scope, element, attrs) ->
      element.on 'click', (event) ->
        return if element.hasClass('disabled')

        if window.confirm('コピーしてもよろしいですか？')
          element.addClass('disabled')
          toaster.pop 'wait', "Now Copying ...", '', 0, 'trustedHtml'

          scope.sourceList.copyMember2AmatsukaList()
          .then (data) ->
            element.removeClass('disabled')
            toaster.clear()

            $rootScope.$broadcast 'list:copyMember', data

            # コピー終了を通知
            toaster.pop 'success', "Finished copy member", '', 2000, 'trustedHtml'