_          = require 'lodash'
request    = require 'request'
cheerio    = require 'cheerio'
NodeCache  = require 'node-cache'
{Promise}  = require 'es6-promise'
{my}       = require './my'
{settings} = if process.env.NODE_ENV is "production"
  require './configs/production'
else
  require './configs/development'

class TwitterClientDefine
  constructor: (@user) ->

  getViaAPI: (params) ->
    return new Promise (resolve, reject) =>
      settings.twitterAPI[params.method] params.type,
        params.params
      , @user.twitter_token
      , @user.twitter_token_secret
      , (error, data, response) ->
        console.log data.length
        if error
          console.log "twitter.#{params.method} error =  ", error
          return reject error
        return resolve data

  postViaAPI: (params) ->
    return new Promise (resolve, reject) =>
      settings.twitterAPI[params.method] params.type,
        params.params
      , @user.twitter_token
      , @user.twitter_token_secret
      , (error, data, response) ->
        console.log data.length
        if error
          console.log "twitter.#{params.method} error =  ", error
          return reject error
        return resolve data


module.exports = class TwitterClient extends TwitterClientDefine

  # 自分のTLを表示
  getHomeTimeline: () ->
    @getViaAPI
      method: 'getTimeline'
      type: 'home_timeline'
      params: ''

  # 他ユーザのTLを表示
  getUserTimeline: (params) ->
    @getViaAPI
      method: 'user_timeline'
      type: 'home_timeline'
      params:
        user_id: params.twitterIdStr || params.screenName

  # 自分のリストを列挙
  getListsList: ->
    @getViaAPI
      method: 'lists'
      type: 'list'
      params: ''

  # 自分の指定のリストのツイートを列挙
  getListsStatuses: (params) ->
    @getViaAPI
      method: 'lists'
      type: 'statuses'
      params:
        list_id: params.listIdStr

  getListsShow: (params) ->
    @getViaAPI
      method: 'lists'
      type: 'show'
      params:
        list_id: params.listIdStr

  getListsMembers: (params) ->
    @getViaAPI
      method: 'lists'
      type: 'members'
      params:
        list_id: params.listIdStr

  # 自分の指定のリストのツイートから画像だけを表示

  # リストの作成
  createLists: (params) ->
    @postViaAPI
      method: 'lists'
      type: 'create'
      params:
        name: params.name
        mode: params.mode

  # リストの削除
  destroyLists: (params) ->
    @postViaAPI
      method: 'lists'
      type: 'destroy'
      params:
        list_id: params.listIdStr

  # 非公開リストにユーザを追加する(単数)
  createMemberList: (params) ->
    @postViaAPI
      method: 'lists'
      type: 'members/create'
      params:
        list_id: params.listIdStr
        user_id: params.twitterIdStr

  getMyFollowing: ->
    @getViaAPI
      method: 'friends'
      type: 'list'
      params:
        user_id: @user._json.id_str
        count: settings.FRINEDS_LIST_COUNT

  getUserIds: (params) =>
    @getViaAPI
      method: 'friends'
      type: 'list'
      params:
        user_id: params.user.id_str
