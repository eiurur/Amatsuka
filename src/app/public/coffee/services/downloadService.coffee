angular.module "myApp.services"
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
