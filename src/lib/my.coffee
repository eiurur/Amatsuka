_       = require 'lodash'
util    = require 'util'
atob    = require 'atob'
moment  = require 'moment'
crypto  = require 'crypto'
request = require 'request'
Promise = require 'bluebird'

my = ->

  c: (desciption, str) ->
    desciption = desciption || ''
    str = str || ''
    console.log "#{desciption}: #{str}"

  e: (desciption, str) ->
    desciption = desciption || ''
    str = str || ''
    console.error "#{desciption}: #{str}"

  dump: (obj) ->
    console.log util.inspect(obj,false,null)

  include: (array, str) ->
    !array.every (elem, idx, array) ->
      str.indexOf(elem) is -1

  createParams: (params) ->
    ("#{k}=#{v}" for k, v of params).join('&')
    # => 'key=apikey&code=01234&start=0&rows=0'

  # UNIXTIMEを返す
  # 引数なし -> 現在時刻のUNIXTIME
  # 引数あり -> 指定時刻のUNIXTIME
  formatX: (time) ->
    if time?
      moment(time).format("X")
    else
      moment().format("X")

  formatYMD: (time) ->
    if time?
      moment(new Date(time)).format("YYYY-MM-DD")
    else
      moment().format("YYYY-MM-DD")

  formatYMDHms: (time) ->
    if time?
      moment(new Date(time)).format("YYYY-MM-DD HH:mm:ss")
    else
      moment().format("YYYY-MM-DD HH:mm:ss")

  # second秒後の時刻をYYYY-MM-DD HH:mm:ss　の形式で返す
  addSecondsFormatYMDHms: (seconds, time) ->
    if time?
      moment(new Date(time)).add(seconds, 's').format("YYYY-MM-DD HH:mm:ss")
    else
      moment().add(seconds, 's').format("YYYY-MM-DD HH:mm:ss")

  # 引数の日の終わり間際の時間をYYYY-MM-DD 23:59:59 の形式で返す
  endBrinkFormatYMDHms: (time) ->
    if time?
      moment(time + " 23:59:59").format("YYYY-MM-DD HH:mm:ss")

  # 引数の日の開始直後の時間をYYYY-MM-DD 00:00:00 の形式で返す
  rigthAfterStartingFormatYMDHms: (time) ->
    if time?
      moment(time + " 00:00:00").format("YYYY-MM-DD HH:mm:ss")

  # 開始時刻と終了時刻が同じ日かどうか判定
  isSameDay: (startTimeYMD, endTimeYMD) ->
    if startTimeYMD is endTimeYMD then true else false

  # ハッシュ化
  createHash: (key, algorithm) ->
    algorithm = algorithm or "sha256"
    crypto.createHash(algorithm).update(key).digest "hex"

  random: (array) ->
    array[Math.floor(Math.random() * array.length)]

  randomByLimitNum: (array, num) ->
    result = []

    if array.length < num
      result = [].concat array
      console.log """
      num =  #{num} array = #{array.length}, result = #{result.length}
      """
      return result

    while result.length < num
      pluckedVal = @random(array)
      continue if _.contains result, pluckedVal
      result.push pluckedVal
      # HACK: 上の2行は 下の1行でいいんじゃね？
      # result = _.uniq result
    result

  # For TwitterAPI
  # max_idは自分のIDも含むため、1だけデクリメントしないとダメ。
  # それ用の関数。
  decStrNum: (n) ->
    n = n.toString()
    result = n
    i = n.length - 1
    while i > -1
      if n[i] == '0'
        result = result.substring(0, i) + '9' + result.substring(i + 1)
        i -= 1
      else
        result =
          result.substring(0, i) +
          (parseInt(n[i], 10) - 1).toString() +
          result.substring(i + 1)
        return result
    result

  loadBase64Data: (url) ->
    new Promise (resolve, reject) ->
      request
        url: url
        encoding: null
      , (err, res, body) ->
        if err or res.statusCode isnt 200 then return reject err
        base64prefix = 'data:' + res.headers['content-type'] + ';base64,'
        image = body.toString('base64')
        return resolve(base64prefix + image)

  promiseWhile: (condition, action) ->
    resolver = Promise.defer()

    loop_ = ->
      if !condition()
        return resolver.resolve()
      Promise.cast(action()).then(loop_).catch resolver.reject

    process.nextTick loop_
    resolver.promise

  delayPromise: (ms) ->
    return new Promise (resolve) -> setTimeout resolve, ms

exports.my = my()