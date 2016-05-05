angular.module "myApp.factories"
  .factory 'WindowScrollableSwitcher', ->
    class WindowScrollableSwitcher
      constructor: ->

      @enableScrolling: ->
        window.onscroll = ->
        return

      @disableScrolling: ->
        x = window.scrollX
        y = window.scrollY
        window.onscroll = ->
          window.scrollTo x, y

    WindowScrollableSwitcher