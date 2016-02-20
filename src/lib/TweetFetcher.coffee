moment           = require 'moment'
_                = require 'lodash'
path             = require 'path'
chalk            = require 'chalk'
TwitterClient    = require path.resolve 'build', 'lib', 'TwitterClient'
{my}             = require path.resolve 'build', 'lib', 'my'
{twitterUtils}   = require path.resolve 'build', 'lib', 'twitterUtils'
settings         = if process.env.NODE_ENV is 'production'
  require path.resolve 'build', 'lib', 'configs', 'production'
else
  require path.resolve 'build', 'lib', 'configs', 'development'


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
            includeRetweet: @config.includeRetweet
        when 'getHomeTimeline', 'getUserTimeline'
          params =
            twitterIdStr: @req.params.id
            maxId: @maxId
            count: @req.params.count
            includeRetweet: @req.query.isIncludeRetweet or @config.includeRetweet
        when 'getFavLists'
          params =
            twitterIdStr: @req.params.id
            maxId: @req.params.maxId
            count: @req.params.count
        else
      return params


    fetchTweet: (maxId) ->
      # console.log chalk.bgGreen 'fetchTWeet =============> '
      # console.log chalk.green 'maxId =============> '
      # console.log maxId
      # console.log @req.params.maxId
      @maxId = maxId or @req.params.maxId

      params = @getRequestParams()
      if _.isEmpty params then res.json data: {}

      # console.log chalk.blue 'Before params =============> '
      # console.log "#{@queryType} ", params

      twitterClient = new TwitterClient(@req.session.passport.user)
      twitterClient[@queryType](params)
      .then (tweets) =>
        # console.log chalk.cyan 'tweets.length =============> '
        # console.log "#{@queryType} ", tweets.length

        # API限界まで読み終えたとき
        if tweets.length is 0 then @res.json data: []

        nextMaxId = _.last(tweets).id_str

        tweetsNormalized = twitterUtils.normalizeTweets tweets, @config

        # console.log "#{@queryType} !_.isEmpty tweetsNormalized = ", !_.isEmpty tweetsNormalized

        if !_.isEmpty tweetsNormalized then @res.json data: tweetsNormalized

        console.log chalk.red 'maxId, nextMaxId =============> '
        console.log maxId
        console.log nextMaxId

        if @maxId is nextMaxId then @res.json data: []

        nextMaxIdDeced = my.decStrNum nextMaxId

        @fetchTweet(nextMaxIdDeced)
      .catch (error) =>
        @res.json error: error