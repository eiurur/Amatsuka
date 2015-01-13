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


module.exports = class TwitterClient

  constructor: (@user) ->

    # 初ログインのとき用
    # if _.isUndefined user.accessTokenSecret
    #   @user = user

    # Cronのときのタイムライン更新用
    # @user =
    #   # twitter_token: user.accessToken
    #   # twitter_token_secret: user.accessTokenSecret
    #   # _json:
    #   #   id_str: user.twitterIdStr

    #   twitter_token: user.access_token
    #   twitter_token_secret: user.access_token_secret
    #   _json:
    #     id_str: user.id_str

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

  # 自分のTLを表示
  getHomeTimeline: () ->
    return new Promise (resolve, reject) =>
      settings.twitterAPI.getTimeline 'home_timeline',
        ''
      , @user.twitter_token
      , @user.twitter_token_secret
      , (error, data, response) ->
        console.log data.length
        if error
          console.log 'twitter.get.home_timeline error =  ', error
          return reject
        return resolve data

  # 他ユーザのTLを表示
  getUserTimeline: (params) ->
    return new Promise (resolve, reject) =>
      settings.twitterAPI.getTimeline 'user_timeline',
        user_id: params.twitterIdStr || params.screenName
      , @user.twitter_token
      , @user.twitter_token_secret
      , (error, data, response) ->
        console.log data.length
        if error
          console.log 'twitter.get.user_timeline error =  ', error
          return reject
        return resolve data

  # 自分のTLから画像だけを表示

  # 自分のリストを列挙
  getListsList: () ->
    return new Promise (resolve, reject) =>
      settings.twitterAPI.lists  'list',
        ''
      , @user.twitter_token
      , @user.twitter_token_secret
      , (error, data, response) ->
        console.log data.length
        if error
          console.log 'twitter.get.lists/list error =  ', error
          return reject
        return resolve data

  # 自分の指定のリストのツイートを列挙
  getListsStatuses: (params) ->
    return new Promise (resolve, reject) =>
      settings.twitterAPI.lists 'statuses',
        list_id: params.listIdStr
      , @user.twitter_token
      , @user.twitter_token_secret
      , (error, data, response) ->
        console.log data.length
        if error
          console.log 'twitter.get.lists/statuses error =  ', error
          # return reject
        return resolve data

  getListsShow: (params) ->
    console.log params
    return new Promise (resolve, reject) =>
      settings.twitterAPI.lists  'show',
        list_id: params.listIdStr
      , @user.twitter_token
      , @user.twitter_token_secret
      , (error, data, response) ->
        console.log data.length
        # TODO: 後で消す
        # unless data.name is 'Amatsuka'
        #   console.log 'twitter.get.lists/show error =  ', error
        #   return reject err
        return resolve data

  getListsMembers: (params) ->
    console.log params
    return new Promise (resolve, reject) =>
      settings.twitterAPI.lists  'members',
        list_id: params.listIdStr
      , @user.twitter_token
      , @user.twitter_token_secret
      , (error, data, response) ->
        console.log data.length
        if error
          console.log 'twitter.get.lists/members error =  ', error
          return reject
        return resolve data

  # 自分の指定のリストのツイートから画像だけを表示

  # リストの作成
  createLists: (params) ->
    return new Promise (resolve, reject) =>
      settings.twitterAPI.lists  'create',
        name: params.name
        mode: params.mode
      , @user.twitter_token
      , @user.twitter_token_secret
      , (error, data, response) ->
        console.log data
        if error
          console.log 'twitter.get.lists/create error =  ', error
          return reject
        return resolve data

  # リストの削除
  destroyLists: (params) ->
    return new Promise (resolve, reject) =>
      settings.twitterAPI.lists  'destroy',
        list_id: params.listIdStr
      , @user.twitter_token
      , @user.twitter_token_secret
      , (error, data, response) ->
        console.log data
        if error
          console.log 'twitter.get.lists/destroy error =  ', error
          return reject
        return resolve data

  # 非公開リストにユーザを追加する(単数)
  createMemberList: (params) ->
    return new Promise (resolve, reject) =>
      settings.twitterAPI.lists  'members/create',
        list_id: params.listIdStr
        user_id: params.twitterIdStr
      , @user.twitter_token
      , @user.twitter_token_secret
      , (error, data, response) ->
        console.log data
        if error
          console.log 'twitter.get.members/create error =  ', error
          return reject
        return resolve data



  getMyFollowing: =>
    return new Promise (resolve, reject) =>
      console.log 'getMyFollowing @user = ', @user.twitter_token
      console.log 'getMyFollowing @user = ', @user.twitter_token_secret
      settings.twitterAPI.friends 'list',
        user_id: @user._json.id_str
        count: settings.FRINEDS_LIST_COUNT
      , @user.twitter_token
      , @user.twitter_token_secret
      , (error, data, response) ->
        if error
          console.log 'twitter.get.myfollowing error =  ', error
          return reject
        return resolve data.users

  getUserIds: (user) =>
    return new Promise (resolve, reject) =>
      settings.twitterAPI.friends 'ids',
        user_id: user.id_str
      , @user.twitter_token
      , @user.twitter_token_secret
      , (error, data, response) ->
        if error
          console.log 'twitter.get.following error =  ', error
          return reject
        return resolve data.ids

  getUsersIdsFollowingFollowing: (users) ->
    return Promise.all _.map users, (user) =>
      @getUserIds user
