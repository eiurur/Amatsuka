mongoose   = require 'mongoose'
BaseProvider = require './BaseProvider'
Schema     = mongoose.Schema
ObjectId   = Schema.ObjectId

TweetSchema = new Schema
  postedBy:
    type: ObjectId
    ref: 'Illustrator'
    index: true
  tweet:
    type: ObjectId
    ref: 'PictTweet'

RankingSchema = new Schema
  year:
    type: Date
    default: Date.now()
  tweets: [TweetSchema]
  updatedAt:
    type: Date
    default: Date.now()


mongoose.model 'Ranking', RankingSchema

RankingSchema.index year: -1

Ranking        = mongoose.model 'Ranking'

module.exports = class RankingProvider extends BaseProvider

  constructor: ->
    super(Ranking)

  find: (params) ->
    return new Promise (resolve, reject) ->
      console.log "\n============> Ranking find\n"
      console.log params
      console.time 'Ranking find'
      Ranking.find {}
      .limit params.limit or 100
      .skip params.skip or 0
      # .populate 'postedBy'
      .sort updatedAt: -1
      .exec (err, tweets) ->
        console.timeEnd 'Ranking find'
        if err then return reject err
        return resolve tweets

  # findByIllustratorObjectId: (params) ->
  #   return new Promise (resolve, reject) ->
  #     console.log "\n============> Pict findByIllustratorObjectId\n"
  #     # console.log params
  #     console.time 'Pict findByIllustratorObjectId'
  #     Pict.findOne(postedBy: params.postedBy)
  #     .populate 'postedBy'
  #     .sort updatedAt: -1
  #     .exec (err, pictList) ->
  #       console.timeEnd 'Pict findByIllustratorObjectId'
  #       if err then return reject err
  #       return resolve pictList

  findOneAndUpdate: (params) ->
    return new Promise (resolve, reject) =>
      console.log params
      query = year: params.year
      data = params
      data.updateAt = new Date()
      options = 'new': true, upsert: true
      return resolve super(query, data, options)

  # count: ->
  #   return new Promise (resolve, reject) ->
  #     console.log "\n============> Pict count\n"
  #     console.time 'Pict count'
  #     Pict.count {}, (err, count) ->
  #       console.log count
  #       console.timeEnd 'Pict count'
  #       if err then return reject err
  #       return resolve count