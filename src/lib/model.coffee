mongoose = require 'mongoose'
_        = require 'lodash'
uri      = process.env.MONGOHQ_URL || 'mongodb://127.0.0.1/amatsuka'
db       = mongoose.connect uri
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId


##
# Schemaインタフェースを通してモデルの定義を行う
##
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

TLSchema = new Schema
  twitterIdStr:
    type: String
    unique: true
    index: true
  ids:
    [ type: String ]
  createdAt:
    type: Date
    default: Date.now()

ConfigSchema = new Schema
  twitterIdStr:
    type: String
    unique: true
    index: true
  configStr: String



##
# モデルへのアクセス
# mongoose.model 'モデル名', 定義したスキーマクラス
# を通して一度モデルを定義すると、同じ関数を通してアクセスすることができる
##
mongoose.model 'User', UserSchema
mongoose.model 'Illustrator', IllustratorSchema
mongoose.model 'Pict', PictSchema
mongoose.model 'TL', TLSchema
mongoose.model 'Config', ConfigSchema

IllustratorSchema.index twitterIdStr: 1
PictSchema.index twitterIdStr: 1, updatedAt: -1

##
# 定義した時の登録名で呼び出し
##
User        = mongoose.model 'User'
Illustrator = mongoose.model 'Illustrator'
Pict        = mongoose.model 'Pict'
TL          = mongoose.model 'TL'
Config      = mongoose.model 'Config'


class UserProvider

  findUserById: (params, callback) ->
    console.log "\n============> User findUserByID\n"
    # console.log params
    User.findOne
      twitterIdStr: params.twitterIdStr
    , (err, user) ->
      callback err, user

  findAllUsers: (params, callback) ->
    console.log "\n============> User findAllUser\n"
    # console.log params
    User.find {}
    , (err, users) ->
      callback err, users

  findOneAndUpdate: (params, callback) ->
    user = null
    console.log "\n============> User upsert\n"
    # console.log params
    user = params.user
    # maoToken: params.user.maoToken を変更条件にすると既に登録済みのユーザは重複エラーが発生するため、
    # Amatsuka側では今まで通りtwitterIdStrを主キー扱いとする
    User.findOneAndUpdate
      twitterIdStr: params.user.twitterIdStr
    , user,
      upsert: true
    , (err, user) ->
      callback err, user

class IllustratorProvider

  find: (params, callback) ->
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

  findById: (params, callback) ->
    return new Promise (resolve, reject) ->
      console.log "\n============> Illustrator findUserByID\n"
      console.log params
      Illustrator.findOne
        twitterIdStr: params.twitterIdStr
      , (err, user) ->
        if err then return reject err
        return resolve user

  findOneAndUpdate: (params, callback) ->
    illustrator = null
    console.log "\n============> Illustrator upsert\n"
    # console.log params
    illustrator = params.illustrator
    illustrator.updatedAt = Date.now()
    Illustrator.findOneAndUpdate
      twitterIdStr: params.illustrator.twitterIdStr
    , illustrator,
      upsert: true
    , (err, illustrator) ->
      callback err, illustrator

class PictProvider

  find: (params, callback) ->
    return new Promise (resolve, reject) ->
      console.log "\n============> Pict find\n"
      # console.log params
      console.time 'Pict find'
      Pict.find {}
      .limit params.limit or 20
      .skip params.skip or 0
      .populate 'postedBy'
      .sort updatedAt: -1
      .exec (err, pictList) ->
        console.timeEnd 'Pict find'
        if err then return reject err
        return resolve pictList

  findByIllustratorObjectId: (params, callback) ->
    return new Promise (resolve, reject) ->
      console.log "\n============> Pict findByIllustratorObjectId\n"
      # console.log params
      console.time 'Pict findByIllustratorObjectId'
      Pict.find(postedBy: params.postedBy)
      .populate 'postedBy'
      .sort updatedAt: -1
      .exec (err, pictList) ->
        console.timeEnd 'Pict findByIllustratorObjectId'
        if err then return reject err
        return resolve pictList

  findOneAndUpdate: (params) ->
    return new Promise (resolve, reject) ->
      pict = null
      console.log "\n============> Pict upsert\n"
      # console.log params
      pict = params
      pict.updatedAt = new Date()
      Pict.findOneAndUpdate
        postedBy: params.postedBy
      , pict,
        upsert: true
      , (err, data) ->
        if err then return reject err
        return resolve data

  count: ->
    return new Promise (resolve, reject) ->
      console.log "\n============> Pict count\n"
      console.time 'Pict count'
      Pict.count {}, (err, count) ->
        console.log count
        console.timeEnd 'Pict count'
        if err then return reject err
        return resolve count


class TLProvider

  findOneById: (params, callback) ->
    console.log "\n============> TL findOneByID\n"
    # console.log params
    TL.findOne
      twitterIdStr: params.twitterIdStr
    , (err, tl) ->
      callback err, tl

  upsert: (params, callback) ->
    console.log "\n============> TL upsert\n"
    # console.log params.twitterIdStr
    timeline =
      twitterIdStr: params.twitterIdStr
      ids: params.ids
    TL.update
      twitterIdStr: params.twitterIdStr
    ,
      timeline
    , upsert: true
    , (err) ->
      callback err


class ConfigProvider

  findOneById: (params, callback) ->
    console.log "\n============> Config findOneByID\n"
    # console.log params
    Config.findOne
      twitterIdStr: params.twitterIdStr
    , (err, config) ->
      callback err, config

  upsert: (params, callback) ->
    console.log "\n============> Config upsert\n"
    # console.log params
    config =
      twitterIdStr: params.twitterIdStr
      configStr: JSON.stringify(params.config)

    Config.update
      twitterIdStr: params.twitterIdStr
    ,
      config
    , upsert: true
    , (err) ->
      callback err

  findOneAndUpdate: (params, callback) ->
    console.log "\n============> User findOneAndUpdate\n"
    # console.log params
    config =
      twitterIdStr: params.twitterIdStr
      configStr: JSON.stringify(params.config)

    Config.findOneAndUpdate
      twitterIdStr: params.twitterIdStr
    ,
      config
    , upsert: true
    , (err, config) ->
      callback err, config


exports.UserProvider        = new UserProvider()
exports.IllustratorProvider = new IllustratorProvider()
exports.PictProvider        = new PictProvider()
exports.TLProvider          = new TLProvider()
exports.ConfigProvider      = new ConfigProvider()
