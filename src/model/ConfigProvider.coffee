mongoose   = require 'mongoose'
BaseProvider = require './BaseProvider'
Schema     = mongoose.Schema
ObjectId   = Schema.ObjectId

ConfigSchema = new Schema
  twitterIdStr:
    type: String
    unique: true
    index: true
  configStr: String

mongoose.model 'Config', ConfigSchema

Config        = mongoose.model 'Config'

module.exports = class ConfigProvider extends BaseProvider

  constructor: ->
    super(Config)

  findOneById: (params, callback) ->
    return new Promise (resolve, reject) =>
      console.time 'Config findOneById'
      opts = twitterIdStr: params.twitterIdStr
      Config.findOne opts
      .exec (err, config) ->
        console.timeEnd 'Config findOneById'
        if err then return reject err
        return resolve config

  upsert: (params) ->
    return new Promise (resolve, reject) =>
      console.log params
      query = twitterIdStr: params.twitterIdStr
      data =
        twitterIdStr: params.twitterIdStr
        configStr: JSON.stringify(params.config)
      options = 'new': true, upsert: true
      return resolve @update(query, data, options)

  findOneAndUpdate: (params) ->
    return new Promise (resolve, reject) =>
      console.log params
      query = twitterIdStr: params.twitterIdStr
      data =
        twitterIdStr: params.twitterIdStr
        configStr: JSON.stringify(params.config)
      options = 'new': true, upsert: true
      return resolve super(query, data, options)
