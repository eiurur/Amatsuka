# Services
angular.module "myApp.services"
  .service "AuthService", ($http) ->

    findUserById: (twitterIdStr) ->
      $http.post "/api/findUserById", twitterIdStr

    isAuthenticated: ->
      $http.get "/api/isAuthenticated"

    status: isAuthenticated: false

    user: {}