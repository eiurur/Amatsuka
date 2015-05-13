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
  createdAt:
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
mongoose.model 'TL', TLSchema
mongoose.model 'Config', ConfigSchema


##
# 定義した時の登録名で呼び出し
##
User   = mongoose.model 'User'
TL     = mongoose.model 'TL'
Config = mongoose.model 'Config'


class UserProvider

  findUserById: (params, callback) ->
    console.log "\n============> User findUserByID\n"
    console.log params
    User.findOne
      twitterIdStr: params.twitterIdStr
    , (err, user) ->
      callback err, user

  findAllUsers: (params, callback) ->
    console.log "\n============> User findAllUser\n"
    console.log params
    User.find {}
    , (err, users) ->
      callback err, users

  # upsert: (params, callback) ->
  #   user = undefined
  #   console.log "\n============> User upsert\n"
  #   console.log params
  #   user = params.user
  #   User.update
  #     twitterIdStr: params.user.twitterIdStr
  #   , user,
  #     upsert: true
  #   , (err) ->
  #     callback err

  findOneAndUpdate: (params, callback) ->
    user = null
    console.log "\n============> User upsert\n"
    console.log params
    user = params.user
    User.findOneAndUpdate
      twitterIdStr: params.user.twitterIdStr
    , user,
      upsert: true
    , (err, user) ->
      callback err, user


class TLProvider

  findOneById: (params, callback) ->
    console.log "\n============> TL findOneByID\n"
    console.log params
    TL.findOne
      twitterIdStr: params.twitterIdStr
    , (err, tl) ->
      callback err, tl

  upsert: (params, callback) ->
    console.log "\n============> TL upsert\n"
    console.log params.twitterIdStr
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
    console.log params
    Config.findOne
      twitterIdStr: params.twitterIdStr
    , (err, config) ->
      callback err, config

  upsert: (params, callback) ->
    console.log "\n============> Config upsert\n"
    console.log params
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
    console.log params
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


exports.UserProvider   = new UserProvider()
exports.TLProvider     = new TLProvider()
exports.ConfigProvider = new ConfigProvider()
