# Services
angular.module "myApp.services"
  .service "AuthService", ($http) ->

    isAuthenticated: ->
      $http.get "/isAuthenticated"

    # findUserById: (twitterIdStr) ->
    #   $http.post "/api/findUserById", twitterIdStr

    status: isAuthenticated: false

    user: {}