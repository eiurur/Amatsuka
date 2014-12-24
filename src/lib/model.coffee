mongoose = require 'mongoose'
_        = require 'lodash'
uri      = process.env.MONGOHQ_URL || 'mongodb://127.0.0.1/aebs'
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


##
# モデルへのアクセス
# mongoose.model 'モデル名', 定義したスキーマクラス
# を通して一度モデルを定義すると、同じ関数を通してアクセスすることができる
##
mongoose.model 'User', UserSchema
mongoose.model 'TL', TLSchema


##
# 定義した時の登録名で呼び出し
##
User = mongoose.model 'User'
TL = mongoose.model 'TL'


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

  upsert: (params, callback) ->
    user = undefined
    console.log "\n============> User upsert\n"
    console.log params
    user =
      twitterIdStr: params.profile._json.id_str
      name: params.profile.username
      screenName: params.profile.displayName
      icon: params.profile._json.profile_image_url_https
      url: params.profile._json.url
      accessToken: params.profile.twitter_token
      accessTokenSecret: params.profile.twitter_token_secret
    User.update
      twitterIdStr: params.profile._json.id_str
    , user,
      upsert: true
    , (err) ->
      callback err



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


exports.UserProvider  = new UserProvider()
exports.TLProvider  = new TLProvider()
