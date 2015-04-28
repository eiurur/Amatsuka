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

  .service 'DownloadService', ($http) ->
    exec: (url) ->
      $http.post '/api/downloadExec', url: url

  .service 'ConvertService', ->
    base64toBlob: (_base64) ->
      i = undefined
      tmp = _base64.split(',')
      data = atob(tmp[1])
      mime = tmp[0].split(':')[1].split(';')[0]
      arr = new Uint8Array(data.length)
      i = 0
      while i < data.length
        arr[i] = data.charCodeAt(i)
        i++
      blob = new Blob([ arr ], type: mime)
      blob
