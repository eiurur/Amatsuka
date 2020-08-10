_             = require 'lodash'
path          = require 'path'
{my}          = require path.resolve 'build', 'lib', 'my'
TwitterClient = require path.resolve 'build', 'lib', 'TwitterClient'
ModelFactory  = require path.resolve 'build', 'model', 'ModelFactory'

# TODO: illustratorと分離させる
module.exports = class PictCollection
  constructor: (user, illustratorTwitterIdStr, idx = 0) ->
    @twitterClient = new TwitterClient(user)
    @illustrator = twitterIdStr: illustratorTwitterIdStr
    @illustratorRawData = null
    @illustratorDBData = null
    @userPicts = []
    @rankingTweets = []
    @userTimelineMaxId = null
    @isContinue = true
    @PROFILE_REQUEST_INTERVAL = 70 * 1000 * idx
    @USER_TIMELINE_REQUEST_INTERVAL = 4 * 1000

  # For Cron task
  collectProfileAndPicts: ->
    return new Promise (resolve, reject) =>
      console.log 'start collect, @PROFILE_REQUEST_INTERVAL = ', @PROFILE_REQUEST_INTERVAL

      # 間隔を空ける
      my.delayPromise @PROFILE_REQUEST_INTERVAL

      # イラストレーターのプロフィール情報を更新
      .then => @getIllustratorTwitterProfile()
      .then (data) => @setIllustratorRawData(data)
      .then => @getIllustratorRawData()
      .then (illustratorRawData) => @setUserTimelineMaxId(illustratorRawData.status.id_str)
      .then => @normalizeIllustratorData()
      .then => @updateIllustratorData()
      .then (data) => @setIllustratorDBData(data)

      # イラストをAPI限界まで収集して人気順にソートし、上位12件分をDBに保存
      .then => @aggregatePict()
      .then => @updatePictListData(@pickupPictListTop12(@userPicts))
      # .then => @updateRankingData(@rankingTweets)
      .then (data) -> return resolve 'Fin'
      .catch (err) -> return reject err

  ###
  Pict
  ###
  aggregatePict: ->
    my.promiseWhile((=>
      @isContinue
    ), =>
      new Promise (resolve, reject) =>
        my.delayPromise @USER_TIMELINE_REQUEST_INTERVAL
        .then (data) =>
          @twitterClient.getUserTimeline
            twitterIdStr: @illustrator.twitterIdStr
            maxId: @userTimelineMaxId
            count: '200'
            includeRetweet: false
        .then (data) =>

          # API制限くらったら return
          if _.isUndefined(data)
            @isContinue = false
            reject()
            return

          # 全部読み終えたら(残りがないとき、APIは最後のツイートだけ取得する === 1)
          if data.length < 2
            @isContinue = false
            resolve()
            return

          if _.isNull(data[data.length - 1]) or _.isUndefined(data[data.length - 1])
            @isContinue = false
            console.log '_.isNull(data[data.length - 1]) or _.isUndefined(data[data.length - 1])'
            console.log ' _.isEmpty @userPicts = ',  _.isEmpty @userPicts
            reject() if _.isEmpty @userPicts
            resolve()
            return

          @setUserTimelineMaxId my.decStrNum data[data.length - 1].id_str

          originalTweetsWithImage = data.filter (tweet) -> _.has(tweet, 'extended_entities') and !_.isEmpty(tweet.extended_entities.media)

          # ユーザ別
          userTWeets = originalTweetsWithImage.map (tweet) ->
            tweetIdStr: tweet.id_str
            # twitterIdStr: tweet.user.id_str
            # favNum: tweet.favorite_count
            # retweetNum: tweet.retweet_count
            # fileName: "#{tweet.user.screen_name}_#{tweet.id_str}"
            totalNum: tweet.retweet_count + tweet.favorite_count
            mediaUrl: tweet.extended_entities.media[0].media_url_https
            mediaOrigUrl: tweet.extended_entities.media[0].media_url_https+':orig'
            displayUrl: tweet.extended_entities.media[0].display_url
            expandedUrl: tweet.extended_entities.media[0].expanded_url
          @userPicts = @userPicts.concat(userTWeets)

          # ランキング
          rankingTweets = originalTweetsWithImage.map (tweet) ->
            delete tweet.user
            tweetIdStr: tweet.id_str
            tweetStr: JSON.stringify(tweet)
            retweetNum: tweet.retweet_count
            favNum: tweet.favorite_count
            totalNum: tweet.retweet_count + tweet.favorite_count
            createdAt: new Date(tweet.created_at) # CAUTION: RankingのcreatedAtはtweetのcreated_at
          @rankingTweets = @rankingTweets.concat(rankingTweets)
          resolve()
        return
    ).then (data) =>
      console.log "\n\nAll =============>"
      console.log @userPicts.length
      {
        userPicts: @userPicts
        rankingTweets: @rankingTweets
      }
    .catch (err) =>
      console.log 'Reject aggregatePict'
      {
        userPicts: @userPicts
        rankingTweets: @rankingTweets
      }

  pickupPictListTop12: (pictList) ->
    _.chain(pictList)
      .sortBy('totalNum')
      .reverse()
      .slice(0, 12)
      .value()

  updatePictListData: (pickupedPictList) ->
    console.log '===> @illustratorDBData._id :: ', @illustratorDBData._id
    return new Promise (resolve, reject) =>
      opts =
        postedBy: @illustratorDBData._id
        pictTweetList: pickupedPictList
      ModelFactory.create('pict').findOneAndUpdate opts
      .then (data) -> return resolve data
      .catch (err) -> return reject err

  updateRankingData: (tweets) ->
    upsert = (tweet) =>
      return new Promise (resolve, reject) =>
        opts = Object.assign({}, postedBy: @illustratorDBData._id, tweet)
        ModelFactory.create('ranking').findOneAndUpdate opts
        .then (data) -> return resolve data
        .catch (err) -> return reject err
    tasks = tweets.map (tweet) => upsert(tweet)
    Promise.all tasks


  setUserTimelineMaxId: (maxId) ->
    @userTimelineMaxId = maxId


  ###
  Utils (From Front. TweetService)
  ###
  getExpandedURLFromURL: (entities) ->
    if !_.has(entities, 'url') then return ''
    entities.url.urls

  restoreProfileUrl: ->
    expandedUrlListInUrl = @getExpandedURLFromURL(@illustratorRawData.entities)
    _.each expandedUrlListInUrl, (urls) =>
      @illustratorRawData.url = @illustratorRawData.url.replace(urls.url, urls.expanded_url)


  ###
  Illustrator
  ###
  getIllustratorTwitterProfile: ->
    return new Promise (resolve, reject) =>
      @twitterClient.showUsers twitterIdStr: @illustrator.twitterIdStr
      .then (data) -> return resolve data
      .catch (err) -> return reject err

  setIllustratorRawData: (data) ->
    @illustratorRawData = data

  # Twitterユーザがいないとき、@illustratorRawData.status.id_strが参照できず、エラーが生じて落ちる。
  # ちゃんとrejectionがハンドルできる形にするためPromiseで囲う
  getIllustratorRawData: ->
    return new Promise (resolve, reject) =>
      if @illustratorRawData.status?.id_str?
        return resolve @illustratorRawData
      return reject 'getIllustratorRawData Error ::'

  setIllustratorDBData: (data) ->
    @illustratorDBData = data

  #getIllustratorDBData: ->


  # Setの方が統一感ある? 意味的には正規化なんだけど
  normalizeIllustratorData: ->
    @restoreProfileUrl()

    @illustrator =
      twitterIdStr: @illustratorRawData.id_str
      name: @illustratorRawData.name
      screenName: @illustratorRawData.screen_name
      icon: @illustratorRawData.profile_image_url_https
      url: @illustratorRawData.url
      profileBackgroundColor: @illustratorRawData.profile_background_color
      profileBackgroundImageUrl: @illustratorRawData.profile_background_image_url_https
      profileBannerUrl: @illustratorRawData.profile_banner_url
      description: @illustratorRawData.description

  getIllustratorData: ->
    @illustrator

  updateIllustratorData: ->
    return new Promise (resolve, reject) =>
      opts = illustrator: @illustrator
      ModelFactory.create('illustrator').findOneAndUpdate opts
      .then (data) -> resolve data
      .catch (err) -> reject err