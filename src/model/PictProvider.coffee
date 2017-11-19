mongoose   = require 'mongoose'
BaseProvider = require './BaseProvider'
Schema     = mongoose.Schema
ObjectId   = Schema.ObjectId

PictTweetSchema = new Schema
  tweetIdStr: String
  # favNum: Number
  # retweetNumt: Number
  totalNum: Number
  # fileName: String
  mediaUrl: String
  mediaOrigUrl: String
  expandedUrl: String
  displayUrl: String


PictSchema = new Schema
  postedBy:
    type: ObjectId
    ref: 'Illustrator'
    index: true
  pictTweetList: [PictTweetSchema]
  updatedAt:
    type: Date
    default: Date.now()

mongoose.model 'Pict', PictSchema

PictSchema.index twitterIdStr: 1, updatedAt: -1

Pict        = mongoose.model 'Pict'

module.exports = class PictProvider extends BaseProvider

  constructor: ->
    super(Pict)

  find: (params) ->
    return new Promise (resolve, reject) ->
      console.log "\n============> Pict find\n"
      # console.log params
      # console.time 'Pict find'
      Pict.find {}
      .limit params.limit or 20
      .skip params.skip or 0
      .populate 'postedBy'
      .sort updatedAt: -1
      .exec (err, pictList) ->
        # console.timeEnd 'Pict find'
        if err then return reject err
        return resolve pictList

  findByIllustratorObjectId: (params) ->
    return new Promise (resolve, reject) ->
      console.log "\n============> Pict findByIllustratorObjectId\n"
      console.log params
      # console.time 'Pict findByIllustratorObjectId'
      Pict.findOne(postedBy: params.postedBy)
      .populate 'postedBy'
      .sort updatedAt: -1
      .exec (err, pictList) ->
        console.log pictList
        # console.timeEnd 'Pict findByIllustratorObjectId'
        if err then return reject err
        return resolve pictList

  findOneAndUpdate: (params) ->
    return new Promise (resolve, reject) =>
      console.log params
      query = postedBy: params.postedBy
      data = params
      data.updateAt = new Date()
      options = 'new': true, upsert: true
      return resolve super(query, data, options)

  count: ->
    return new Promise (resolve, reject) ->
      console.log "\n============> Pict count\n"
      # console.time 'Pict count'
      Pict.count {}, (err, count) ->
        console.log count
        # console.timeEnd 'Pict count'
        if err then return reject err
        return resolve count