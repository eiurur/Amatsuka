angular.module "myApp.services"
  .service "BlackUserListService", ->
    block:
      set: (idList) ->
        localStorage.setItem 'amatsuka.blockIdList', JSON.stringify(idList)

      get: ->
        return JSON.parse(localStorage.getItem 'amatsuka.blockIdList') || {}


    mute:
      set: (idList) ->
        localStorage.setItem 'amatsuka.muteIdList', JSON.stringify(idList)

      get: ->
        return JSON.parse(localStorage.getItem 'amatsuka.muteIdList') || {}

