# Services
angular.module "myApp.services"
  .service "MaoService", ($http) ->

    findByMaoTokenAndDate: (qs) ->
      $http.get "/api/mao?#{qs}"

    countTweetByMaoTokenAndDate: (qs) ->
      $http.get "/api/mao/tweets/count?#{qs}"

    aggregateTweetCount: (qs) ->
      $http.get "/api/mao/stats/tweet/count?#{qs}"