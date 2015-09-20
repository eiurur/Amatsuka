# Services
angular.module "myApp.services", []
  .service "CommonService", ->
    isLoaded: false

  .service 'ToasterService', (toaster) ->
    success: (notify) ->
      console.log notify.title
      toaster.pop 'success', notify.title, notify.text, 2000, 'trustedHtml'

    warning: (notify) ->
      console.log notify.title
      toaster.pop 'warning', notify.title, notify.text, 2000, 'trustedHtml'

  .service 'DownloadService', ($http, ConvertService) ->
    exec: (url, filename, idx) ->
      $http.post '/api/download', url: url
      .success (data) =>
        blob = ConvertService.base64toBlob data.base64Data
        ext = /media\/.*\.(png|jpg|jpeg):orig/.exec(url)[1]
        filename = "#{filename}_#{idx}.#{ext}"
        this.saveAs blob, filename

    saveAs: (blob, filename) ->
      if navigator.appVersion.toString().indexOf('.NET') > 0
        window.navigator.msSaveBlob blob, filename
      else
        a = document.createElement('a')
        document.body.appendChild a
        a.style = 'display: none'
        a.href = window.URL.createObjectURL(blob)
        a.download = filename
        a.click()

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