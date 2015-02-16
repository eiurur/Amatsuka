# Services
angular.module "myApp.services"
  .service "ConfigService", ($http) ->

    getDisplayFormat: =>
      ls = localStorage
      @displayFormat = JSON.parse(ls.getItem 'displayFormat') || 'list'

    setDisplayFormat: =>
      ls = localStorage
      ls.setItem 'displayFormat', @displayFormat

    toggleDisplayFormat: =>
      @displayFormat = if @displayFormat is 'list' then 'grid' else 'list'

    toggleIncludeRetweet: =>
      @isIncludeRetweet = !@isIncludeRetweet

    displayFormat: 'list'

    isIncludeRetweet: true
