# Services
angular.module "myApp.services", []
  .service "CommonService", ->
    isLoaded: false

  .service 'ToasterService', (toaster) ->
    success: (notify) ->
      console.log notify.title
      toaster.pop 'success', notify.title, notify.text

    warning: (notify) ->
      console.log notify.title
      toaster.pop 'warning', notify.title, notify.text
