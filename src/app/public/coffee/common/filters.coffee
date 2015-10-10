# Filters
angular.module("myApp.filters", [])
  .filter "interpolate", (version) ->
    (text) ->
      String(text).replace /\%VERSION\%/g, version

  .filter "noHTML", ->
    (text) ->
      if text?
        text.replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/&/, '&amp;')

  .filter 'newlines', ($sce) ->
    (text) ->
      $sce.trustAsHtml(if text? then text.replace(/\n/g, '<br />') else '')

  .filter 'trusted', ($sce) ->
    (url) ->
      $sce.trustAsResourceUrl url

  .filter 'filteringMember', (AmatsukaList) ->
    (members, searchWord) ->
      console.log '===========> '
      console.log list = new AmatsukaList('Amatsuka')
      console.log 'searchWord', searchWord
      return members if !searchWord
      return members if !searchWord.screen_name

      console.log 'AKAKAK'
      newMembers = []
      list.amatsukaMemberList.forEach (element, index, array) ->
        return if newMembers.length > 20
        console.log 'newMembers = ', newMembers
        if element.screen_name.indexOf(searchWord.screen_name) isnt -1
          newMembers.push element

      newMembers


      # return list.amatsukaMemberList.reject (element, index, array) ->
      #   return if array.length is 20
      #   console.log 'array = ', array
      #   return element.screen_name.indexOf searchWord.screen_name is -1

