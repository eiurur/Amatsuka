# Services
angular.module "myApp.services"
  .service "ConfigService", ($http, $q) ->

    config: {}

    set: (config) ->
      @config = config

    get: ->
      return new Promise (resolve, reject) =>
        console.log 'get @pconfig = ', @config
        unless _.isEmpty(@config) then return resolve @config
        @getFromDB()
        .then (config) =>
          console.log 'get @getFromDB() config = ', config
          @set config
          return resolve config

    update: ->
      localStorage.setItem 'amatsuka.config', JSON.stringify(@config)
      return

    init: ->
      @config =
        includeRetweet: true
        ngUsername: []
        ngWord: []
      localStorage.setItem 'amatsuka.config', JSON.stringify(@config)

    getFromDB: ->
      return $q (resolve, reject) ->
        $http.get '/api/config'
          .then (data) ->
            console.log  data
            console.log  _.isNull(data.data)
            if _.isNull(data.data) then return reject 'Not found data'
            return resolve JSON.parse(data.data.configStr)
          .catch (data) ->
            return reject data || 'getFromDB Request failed'

    save2DB: ->
      return $q (resolve, reject) =>
        $http.post '/api/config', config: @config
          .then (data) ->
            return resolve data
          .catch (data) ->
            return reject data || 'save2DB Request failed'