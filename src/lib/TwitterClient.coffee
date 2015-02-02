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
        # console.log data
        if error
          console.log "In getViaAPI twitter.#{params.method}.#{params.type} error =  ", error
          return reject error
        return resolve data

  postViaAPI: (params) ->
    return new Promise (resolve, reject) =>
      settings.twitterAPI[params.method] params.type,
        params.params
      , @user.twitter_token
      , @user.twitter_token_secret
      , (error, data, response) ->
        # console.log data
        if error
          console.log "In getViaAPI twitter.#{params.method}.#{params.type} error =  ", error
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


  # 自分の指定のリストのツイートから画像だけを表示

  ###
  List
  ###
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

  # リストの情報を表示
  getListsShow: (params) ->
    @getViaAPI
      method: 'lists'
      type: 'show'
      params:
        list_id: params.listIdStr

  # リストのメンバーを表示
  getListsMembers: (params) ->
    @getViaAPI
      method: 'lists'
      type: 'members'
      params:
        list_id: params.listIdStr
        user_id: params.twitterIdStr || ''
        scren_name: params.screenName || ''

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

  # リストにユーザを追加する(単数)
  createListsMembers: (params) ->
    @postViaAPI
      method: 'lists'
      type: 'members/create'
      params:
        list_id: params.listIdStr
        user_id: params.twitterIdStr

  # リストからユーザを削除
  destroyListsMembers: (params) ->
    @getViaAPI
      method: 'lists'
      type: 'show'
      params:
        list_id: params.listIdStr

  getUserIds: (params) =>
    @getViaAPI
      method: 'friends'
      type: 'list'
      params:
        user_id: params.user.id_str

  ###
  Follow
  ###
  getMyFollowing: ->
    @getViaAPI
      method: 'friends'
      type: 'list'
      params:
        user_id: @user._json.id_str
        count: settings.FRINEDS_LIST_COUNT

  getFollowingList: ->
    @getViaAPI
      method: 'friends'
      type: 'list'
      params:
        user_id: params.twitterIdStr || ''
        scren_name: params.screenName || ''

  getMyFollowersList: ->
    @getViaAPI
      method: 'followers'
      type: 'list'
      params:
        user_id: @user._json.id_str
        count: settings.FRINEDS_LIST_COUNT

  getFollowersList: (params) ->
    @getViaAPI
      method: 'followers'
      type: 'list'
      params:
        user_id: params.twitterIdStr || ''
        scren_name: params.screenName || ''



  ###
  fav
  ###
  getFavList: (params) ->
    @getViaAPI
      method: 'favorites'
      type: 'list'
      params:
        user_id: params.twitterIdStr || ''
        screen_name: params.screenName || ''
        count: params.count || settings.MAX_NUM_GET_FAV_TWEET_FROM_LIST

  createFav: (params) ->
    @postViaAPI
      method: 'favorites'
      type: 'create'
      params:
        id: params.tweetIdStr
        include_entities: true

  destroyFav: (params) ->
    @postViaAPI
      method: 'favorites'
      type: 'destroy'
      params:
        id: params.tweetIdStr


  ###
  ツイート関連(RTを含む)
  ###
  retweetStatus: (params) ->
    @postViaAPI
      method: 'statuses'
      type: 'retweet'
      params:
        id: params.tweetIdStr

  # Note:
  # リツイートを解除したいとき
  # -> このAPIに渡すidはリツイート後のtweet_id。リツイート元ではないよ。
  destroyStatus: (params) ->
    @postViaAPI
      method: 'statuses'
      type: 'destroy'
      params:
        id: params.tweetIdStr

