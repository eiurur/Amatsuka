# Services
angular.module "myApp.services"
  .service "ConfigService", ($http, $q) ->

    config: {}

    # registerConfig2LocalStorage: ->
    #   ls = localStorage
    #   ls.setItem 'amatsuka.config', JSON.stringify(@config)
    #   return

    set: (config) ->
      @config = config


    update: ->
      localStorage.setItem 'amatsuka.config', JSON.stringify(@config)
      return

    init: ->
      @config =
        includeRetweet: true
      localStorage.setItem 'amatsuka.config', JSON.stringify(@config)
      @save2DB().then (data) ->

    getFromDB: ->
      return $q (resolve, reject) ->
        $http.get '/api/config'
          .success (data) ->
            # console.log typeof data.data.configStr
            console.log _.isEmpty JSON.parse(data.data.configStr)
            if _.isEmpty JSON.parse(data.data.configStr) then return reject 'Not found data'
            return resolve JSON.parse(data.data.configStr)
          .error (data) ->
            return reject data || 'getFromDB Request failed'

    save2DB: ->
      return $q (resolve, reject) =>
        $http.post '/api/config', config: @config
          .success (data) ->
            return resolve data
          .error (data) ->
            return reject data || 'save2DB Request failed'