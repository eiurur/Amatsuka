# Directives
angular.module "myApp.directives"
  .directive "appVersion", (version) ->
    (scope, elm, attrs) ->
      elm.text version
      return