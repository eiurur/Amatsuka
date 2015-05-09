assert                         = require 'power-assert'
mongoose                       = require 'mongoose'
{UserProvider, ConfigProvider} = require "../build/lib/model"

mongoose.createConnection 'mongodb://127.0.0.1/amatsuka_test'

describe 'User', ->
  currentUser = null

  before (done) ->
    user =
      twitterIdStr: 'twitterIdStr_test'
      name: 'name_test'
      screenName: 'screenName_test'
      icon: 'icon_test'
      url: 'url_test'
      accessToken: 'accessToken_test'
      accessTokenSecret: 'accessTokenSecret_test'

    UserProvider.upsert
      user: user
    , (err) ->
      currentUser = user
      do done

  after (done) ->
    User = mongoose.model 'User'
    User.remove {}, ->
      do done

  describe '#findUserById()', (done) ->
    it 'should get only one user data', ->
      UserProvider.findUserById
        twitterIdStr: currentUser.twitterIdStr
      , (err, data) ->
        assert err is null
        assert currentUser.twitterIdStr is data.twitterIdStr
        assert currentUser.name is data.name
        assert data.data.length is 7
        do done

  describe '#findAllUsers()', (done) ->
    it 'should get one user data', ->
      UserProvider.findAllUsers
        twitterIdStr: currentUser.twitterIdStr
      , (err, data) ->
        assert err is null
        assert data.length is 1
        do done

  describe '#findOneAndUpdate()', (done) ->
    it 'should update the name from name_test to name_test_new', (done) ->
      user =
        twitterIdStr: 'twitterIdStr_test2'
        name: 'name_test2'
      UserProvider.findOneAndUpdate
        user: user
      , (err, data) ->
        assert err is null
        assert data.twitterIdStr is 'twitterIdStr_test2'
        assert data.name is 'name_test2'
        do done

    it 'should insert new user data', (done) ->
      user =
        twitterIdStr: 'twitterIdStr_test'
        name: 'name_test_new'
      UserProvider.findOneAndUpdate
        user: user
      , (err, data) ->
        assert err is null
        assert data.twitterIdStr is 'twitterIdStr_test'
        assert data.name is 'name_test_new'
        do done


describe 'Config', ->
  currentConfig = null

  before (done) ->
    config =
      twitterIdStr: 'twitterIdStr_test'
      config: {includeRetweet: true}

    ConfigProvider.upsert
      twitterIdStr: 'twitterIdStr_test'
      config: {includeRetweet: true}
    , (err) ->
      currentConfig = config
      do done

  after (done) ->
    Config = mongoose.model 'Config'
    Config.remove {}, ->
      do done

  describe '#findUserById()', (done) ->
    it 'should get only one config data', ->
      ConfigProvider.findOneById
        twitterIdStr: currentConfig.twitterIdStr
      , (err, data) ->
        assert err is null
        assert currentConfig.twitterIdStr is data.twitterIdStr
        assert typeof data.configStr is 'string'
        assert typeof JSON.parse(data.configStr) is 'object'
        assert data.data.length is 3
        do done

  describe '#upsert()', (done) ->
    it 'should update config property', (done) ->
      ConfigProvider.upsert
        twitterIdStr: 'twitterIdStr_test'
        config: {includeRetweet: false}
      , (err) ->
        assert err is null
        do done

  describe '#findOneAndUpdate()', (done) ->
    it 'should update config property', (done) ->
      ConfigProvider.findOneAndUpdate
        twitterIdStr: 'twitterIdStr_test'
        config: {includeRetweet: false}
      , (err, data) ->
        assert err is null
        assert data.twitterIdStr is 'twitterIdStr_test'
        assert JSON.parse(data.configStr).includeRetweet is false
        do done

    it 'should insert new config data', (done) ->
      ConfigProvider.findOneAndUpdate
        twitterIdStr: 'twitterIdStr_test2'
        config: {includeRetweet: true}
      , (err, data) ->
        assert err is null
        assert data.twitterIdStr is 'twitterIdStr_test2'
        assert JSON.parse(data.configStr).includeRetweet is true
        do done