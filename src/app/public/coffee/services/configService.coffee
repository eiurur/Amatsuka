# Services
angular.module "myApp.services"
  .service "ConfigService", ($http, $q) ->

    config: {}

    # registerConfig2LocalStorage: ->
    #   ls = localStorage
    #   ls.setItem 'amatsuka.config', JSON.stringify(@config)
    #   return

    update: ->
      localStorage.setItem 'amatsuka.config', JSON.stringify(@config)
      return

    init: ->
      @config =
        includeRetweet: true
      localStorage.setItem 'amatsuka.config', JSON.stringify(@config)

    getFromDB: ->
      return $q (resolve, reject) ->
        $http.get '/api/config'
          .success (data) ->
            return resolve data
          .error (data) ->
            return reject data || 'getFromDB Request failed'

    save2DB: ->
      return $q (resolve, reject) =>
        $http.post '/api/config', config: @config
          .success (data) ->
            return resolve data
          .error (data) ->
            return reject data || 'save2DB Request failed'