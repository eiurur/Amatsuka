mongoose   = require 'mongoose'
BaseProvider = require './BaseProvider'
Schema     = mongoose.Schema
ObjectId   = Schema.ObjectId


UserSchema = new Schema
  twitterIdStr:
    type: String
    unique: true
    index: true
  name: String
  screenName:String
  icon: String
  url: String
  accessToken: String
  accessTokenSecret: String
  maoToken: String
  createdAt:
    type: Date
    default: Date.now()
  updatedAt:
    type: Date
    default: Date.now()

mongoose.model 'User', UserSchema

User        = mongoose.model 'User'

module.exports = class UserProvider extends BaseProvider

  constructor: ->
    super(User)

  # findUserById: (params, callback) ->
  #   console.log "\n============> User findUserByID\n"
  #   # console.log params
  #   User.findOne
  #     twitterIdStr: params.twitterIdStr
  #   , (err, user) ->
  #     callback err, user

  # maoToken: params.user.maoToken を変更条件にすると既に登録済みのユーザは重複エラーが発生するため、
  # Amatsuka側では今まで通りtwitterIdStrを主キー扱いとする
  findOneAndUpdate: (params) ->
    return new Promise (resolve, reject) =>
      query = twitterIdStr: params.user.twitterIdStr
      data = params.user
      data.updatedAt = Date.now()
      options = 'new': true, upsert: true
      return resolve super(query, data, options)
