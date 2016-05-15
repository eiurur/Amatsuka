angular.module "myApp.services"
  .service "StatService", ($http, $q) ->
    # getTweetCountRanking: (params) ->
    #   return $q (resolve, reject) =>
    #     $http.get "/api/mao/stats/tweet/count?#{qs}"
