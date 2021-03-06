_                = require 'lodash'
path             = require 'path'
TwitterClient    = require path.resolve 'build', 'lib', 'TwitterClient'
{my}             = require path.resolve 'build', 'lib', 'my'
{twitterUtils}   = require path.resolve 'build', 'lib', 'twitterUtils'

# JSON API
module.exports = class TweetFetcher

    constructor: (@req, @res, @queryType, @maxId, @config) ->

    getRequestParams: () ->
      params = {}
      switch @queryType
        when 'getListsStatuses'
          params =
            listIdStr: @req.params.id
            maxId: @maxId
            count: @req.params.count
            includeRetweet: @config.isIncludeRetweet
        when 'getHomeTimeline', 'getUserTimeline'
          params =
            twitterIdStr: @req.params.id
            maxId: @maxId
            count: @req.params.count
            includeRetweet: @req.query.isIncludeRetweet or @config.isIncludeRetweet
        when 'getFavLists'
          params =
            twitterIdStr: @req.params.id
            maxId: @maxId
            count: 100
        else
      return params


    fetchTweet: (maxId) ->
      @maxId = maxId or @req.params.maxId
      params = @getRequestParams()
      if _.isEmpty params 
        @res.send {}
      else
        twitterClient = new TwitterClient(@req.session.passport.user)
        twitterClient[@queryType](params)
        .then (tweets) =>
          # API限界まで読み終えたとき
          if tweets.length is 0 
            @res.send []
            return

          nextMaxId = _.last(tweets).id_str

          # 最後まで読み終えたとき
          if @maxId is nextMaxId 
            @res.send []
            return

          tweetsNormalized = twitterUtils.normalizeTweets tweets, @config

          if !_.isEmpty tweetsNormalized 
            @res.send tweetsNormalized
            return

          nextMaxIdDeced = my.decStrNum nextMaxId

          @fetchTweet(nextMaxIdDeced)
        .catch (error) =>
          @res.status(429).json error: error
