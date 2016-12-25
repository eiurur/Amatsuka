path           = require 'path'
EggSlicer      = require 'egg-slicer'
_              = require 'lodash'
Promise        = require "bluebird"
PictCollection = require path.resolve 'build', 'lib', 'PictCollection'
{settings}     = require path.resolve 'build', 'lib', 'configs', 'settings'
ModelFactory   = require path.resolve 'build', 'model', 'ModelFactory'

exports.cronTaskCollectPicts = ->
  ModelFactory.create('illustrator').find()
  .then (profileList) ->
    console.log profileList.length
    console.log settings.TWS
    console.log settings.TWS.length

    # 1人で回しても終わらないので並列で収集する。
    slicedProfileList = EggSlicer.slice(profileList, settings.TWS.length)
    slicedProfileList.map (pl, i) =>
      user =
        _json:
          id_str: settings.TWS[i].TW_ID_STR
        twitter_token: settings.TWS[i].TW_AT
        twitter_token_secret: settings.TWS[i].TW_AS

      promises = []
      pl.forEach (profile, idx) ->
        pictCollection = new PictCollection(user, profile.twitterIdStr, idx)
        promises.push pictCollection.collectProfileAndPicts()

      Promise.all promises
      .then (resultList) ->
        console.log 'Succeeded!'
        return
      .catch (err) ->
        console.error 'Failed.', err
        return