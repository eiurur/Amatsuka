# Services
angular.module "myApp.services"
  .service "URLParameterService", ($location) ->

    checkURLResourceLength: (urlResourcesLength, allowableLength) -> if urlResourcesLength > allowableLength then $location.path('/')

    getQueryParams: -> $location.search()

    parse: -> $location.path().split('/')
