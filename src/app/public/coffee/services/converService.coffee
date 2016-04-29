angular.module "myApp.services"
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