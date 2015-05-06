# Services
angular.module "myApp.services"
  .service "ConfigService", ($http) ->

    config: {}

    # registerConfig2LocalStorage: ->
    #   ls = localStorage
    #   ls.setItem 'amatsuka.config', JSON.stringify(@config)
    #   return

    update: ->
      ls = localStorage
      ls.setItem 'amatsuka.config', JSON.stringify(@config)
      return

    init: ->
      ls = localStorage
      @config =
        includeRetweet: true
      ls.setItem 'amatsuka.config', JSON.stringify(@config)