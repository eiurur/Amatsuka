mongoose   = require 'mongoose'
BaseProvider = require './BaseProvider'
Schema     = mongoose.Schema
ObjectId   = Schema.ObjectId

IllustratorSchema = new Schema
  twitterIdStr:
    type: String
    unique: true
    index: true
  name: String
  screenName:String
  icon: String
  url: String
  profileBackgroundColor: String
  profileBackgroundImageUrl: String
  profileBannerUrl: String
  description: String
  createdAt:
    type: Date
    default: Date.now()
  updatedAt:
    type: Date
    default: Date.now()

mongoose.model 'Illustrator', IllustratorSchema

IllustratorSchema.index twitterIdStr: 1

Illustrator        = mongoose.model 'Illustrator'

module.exports = class IllustratorProvider extends BaseProvider

  constructor: ->
    super(Illustrator)

  find: (params) ->
    return new Promise (resolve, reject) ->
      console.log "\n============> Illustrator find\n"
      console.time 'Illustrator find'
      # Illustrator.find  {twitterIdStr: 906372890}
      Illustrator.find {}
      .sort updatedAt: -1
      .exec (err, illustratorList) ->
        console.timeEnd 'Illustrator find'
        if err then return reject err
        return resolve illustratorList

  findById: (params) ->
    return new Promise (resolve, reject) ->
      console.log "\n============> Illustrator findUserByID\n"
      console.log params
      opts = twitterIdStr: params.twitterIdStr
      Illustrator.where(opts)
      .findOne (err, user) ->
        if err then return reject err
        return resolve user

  findOneAndUpdate: (params) ->
    return new Promise (resolve, reject) =>
      console.log params
      query = twitterIdStr: params.illustrator.twitterIdStr
      data = params.illustrator
      data.updatedAt = Date.now()
      options = 'new': true, upsert: true
      return resolve super(query, data, options)