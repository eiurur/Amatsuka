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
          console.log "getViaAPI #{params.method}.#{params.type} e = ", error
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
          console.log "postViaAPI #{params.method}.#{params.type} e = ", error
          return reject error
        return resolve data


module.exports = class TwitterClient extends TwitterClientDefine

  # 自分のTLを表示
  getHomeTimeline: (params) ->
    opts =
      count: params.count || settings.MAX_NUM_GET_TIMELINE_TWEET
      include_entities: true
      include_rts: true
    unless params.maxId is '0' || params.maxId is 'undefined'
      opts.max_id = params.maxId
    console.log "opts = ", opts

    @getViaAPI
      method: 'getTimeline'
      type: 'home_timeline'
      params: opts

  # 他ユーザのTLを表示
  getUserTimeline: (params) ->
    opts =
      user_id: params.twitterIdStr
      count: params.count
      include_entities: true
      include_rts: true
    unless params.maxId is '0' || params.maxId is 'undefined'
      opts.max_id = params.maxId
    if params.count is '0' || params.count is 'undefined'
      opts.count = settings.MAX_NUM_GET_TIMELINE_TWEET
    console.log "opts = ", opts

    @getViaAPI
      method: 'getTimeline'
      type: 'user_timeline'
      params: opts

  ###
  Tweet
  ###
  showStatus: (params) ->
    @getViaAPI
      method: 'statuses'
      type: 'show'
      params:
        id: params.tweetIdStr
        include_my_retweet: true
        include_entities: true

  ###
  User
  ###
  showUsers: (params) ->
    @getViaAPI
      method: 'users'
      type: 'show'
      params:
        user_id: params.twitterIdStr || ''
        # scren_name: params.screenName || ''
        include_entities: true


  # 自分の指定のリストのツイートから画像だけを表示

  ###
  List
  ###
  # 自分のリストを列挙
  getListsList: (params) ->
    @getViaAPI
      method: 'lists'
      type: 'list'
      params:
        user_id: params.twitterIdStr || ''
        scren_name: params.screenName || ''
        count: params.count || settings.MAX_NUM_GET_LIST

  # 自分の指定のリストのツイートを列挙
  getListsStatuses: (params) ->
    opts =
      list_id: params.listIdStr
      count: ~~params.count || settings.MAX_NUM_GET_LIST_STATUSES
      include_entities: true
      include_rts: true
    unless params.maxId is '0' || params.maxId is 'undefined'
      opts.max_id = params.maxId
    console.log "opts = ", opts

    @getViaAPI
      method: 'lists'
      type: 'statuses'
      params: opts

  # リストの情報を表示
  getListsShow: (params) ->
    @getViaAPI
      method: 'lists'
      type: 'show'
      params:
        list_id: params.listIdStr

  # リストのメンバーを表示
  getListsMembers: (params) ->
    opts =
      list_id: params.listIdStr
      user_id: params.twitterIdStr || ''
      scren_name: params.screenName || ''
      count: ~~params.count || settings.MAX_NUM_GET_LIST_MEMBERS
    @getViaAPI
      method: 'lists'
      type: 'members'
      params: opts

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

  # リストにユーザを追加する(複数)
  createAllListsMembers: (params) ->
    console.log params
    params.twitterIdStr = params.twitterIdStr || settings.defaultUserIds
    @postViaAPI
      method: 'lists'
      type: 'members/create_all'
      params:
        list_id: params.listIdStr
        user_id: params.twitterIdStr

  # リストからユーザを削除
  destroyListsMembers: (params) ->
    @postViaAPI
      method: 'lists'
      type: 'members/destroy'
      params:
        list_id: params.listIdStr
        user_id: params.twitterIdStr

  getUserIds: (params) =>
    @getViaAPI
      method: 'friends'
      type: 'list'
      params:
        user_id: params.user.id_str

  ###
  Follow
  ###
  # getFollowing: ->
  #   @getViaAPI
  #     method: 'friends'
  #     type: 'list'
  #     params:
  #       user_id: params.twitterIdStr || ''
  #       scren_name: params.screenName || ''
  #       count: params.count || settings.FRINEDS_LIST_COUNT

  # フォローイング
  getFollowingList: ->
    @getViaAPI
      method: 'friends'
      type: 'list'
      params:
        user_id: params.twitterIdStr || ''
        scren_name: params.screenName || ''
        count: params.count || settings.FRINEDS_LIST_COUNT

  getMyFollowingList: ->
    @getViaAPI
      method: 'friends'
      type: 'list'
      params:
        user_id: @user._json.id_str
        count: params.count || settings.FRINEDS_LIST_COUNT

  # フォロワー
  getFollowersList: (params) ->
    @getViaAPI
      method: 'followers'
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
        count: params.count || settings.FRINEDS_LIST_COUNT


  ###
  fav
  ###
  getFavLists: (params) ->
    opts =
      user_id: params.twitterIdStr
      count: ~~params.count || settings.MAX_NUM_GET_FAV_TWEET_FROM_LIST
      include_entities: true
    unless params.maxId is '0' || params.maxId is 'undefined'
      opts.max_id = params.maxId
    console.log "opts = ", opts
    @getViaAPI
      method: 'favorites'
      type: 'list'
      params: opts

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
  # -> このAPIに渡すidはリツイート後のtweet_id ( = 自分のtweet_id)。
  destroyStatus: (params) ->
    @showStatus(params)
    .then (data) =>
      @postViaAPI
        method: 'statuses'
        type: 'destroy'
        params:
          id: data.current_user_retweet.id_str

