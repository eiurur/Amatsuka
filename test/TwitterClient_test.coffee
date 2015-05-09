# assert        = require 'power-assert'
# TwitterClient = require '../build/lib/TwitterClient'

# settings      = if process.env.NODE_ENV is 'production'
#   require '../build/lib/configs/production'
# else
#   require '../build/lib/configs/development'


# describe 'TwitterClient GET', ->
#   beforeEach ->
#     @user =
#       _json:
#           id_str: process.env.TEST_TWITTER_IDSTR || settings.TW_ID_STR
#       twitter_token: process.env.TEST_TWITTER_TOKEN || settings.TW_AT
#       twitter_token_secret: process.env.TEST_TWITTER_TOKEN_SECRET || settings.TW_AS
#     @twitterClient = new TwitterClient @user

#   describe 'Module TwitterClient', ->
#     # Tweets individual
#     it 'should have a showStatus Method', ->
#       assert typeof @twitterClient.showStatus is 'function'

#     # User profile
#     it 'should have a showUsers Method', ->
#       assert typeof @twitterClient.showUsers is 'function'

#     # List
#     it 'should have a getListsList Method', ->
#       assert typeof @twitterClient.getListsList is 'function'
#     it 'should have a getListsStatuses Method', ->
#       assert typeof @twitterClient.getListsStatuses is 'function'
#     it 'should have a getListsShow Method', ->
#       assert typeof @twitterClient.getListsShow is 'function'
#     it 'should have a getListsMembers Method', ->
#       assert typeof @twitterClient.getListsMembers is 'function'
#     it 'should have a createLists Method', ->
#       assert typeof @twitterClient.createLists is 'function'
#     it 'should have a destroyLists Method', ->
#       assert typeof @twitterClient.destroyLists is 'function'
#     it 'should have a createListsMembers Method', ->
#       assert typeof @twitterClient.createListsMembers is 'function'
#     it 'should have a createAllListsMembers Method', ->
#       assert typeof @twitterClient.createAllListsMembers is 'function'
#     it 'should have a destroyListsMembers Method', ->
#       assert typeof @twitterClient.destroyListsMembers is 'function'
#     it 'should have a getUserIds Method', ->
#       assert typeof @twitterClient.getUserIds is 'function'
#     it 'should have a getFollowingList Method', ->
#       assert typeof @twitterClient.getFollowingList is 'function'
#     it 'should have a getMyFollowingList Method', ->
#       assert typeof @twitterClient.getMyFollowingList is 'function'
#     it 'should have a getFollowersList Method', ->
#       assert typeof @twitterClient.getFollowersList is 'function'
#     it 'should have a getMyFollowersList Method', ->
#       assert typeof @twitterClient.getMyFollowersList is 'function'

#     # Fav
#     it 'should have a getFavLists Method', ->
#       assert typeof @twitterClient.getFavLists is 'function'
#     it 'should have a createFav Method', ->
#       assert typeof @twitterClient.createFav is 'function'
#     it 'should have a destroyFav Method', ->
#       assert typeof @twitterClient.destroyFav is 'function'

#     # Retweet
#     it 'should have a retweetStatus Method', ->
#       assert typeof @twitterClient.retweetStatus is 'function'
#     it 'should have a destroyStatus Method', ->
#       assert typeof @twitterClient.destroyStatus is 'function'


#   # describe 'getHomeTimeline()', ->
#   #   it 'should return object when the request is sent', ->
#   #     params = count: 10
#   #     @twitterClient.getHomeTimeline params
#   #     .then (data) ->
#   #       assert data is 'object'


#   #   it 'should return 10 when the request is sent', ->
#   #     params = count: 10
#   #     @twitterClient.getHomeTimeline params
#   #     .then (data) ->
#   #       assert data.length is 10


#   describe 'showStatus()', ->
#     it 'should return tweet data when the request is sent. ', ->
#       params = tweetIdStr: '583139347001577472'
#       @twitterClient.showStatus params
#       .then (data) ->
#         assert typeof data is 'object'
#         assert typeof data.id is 'number'
#         assert typeof data.id_str is 'string'

#   describe 'showUsers()', ->
#     it 'should return same user_id when ', ->
#       params = twitterIdStr: @user._json.id_str
#       @twitterClient.showUsers params
#       .then (data) =>
#         assert data.id_str is @user._json.id_str

#   describe 'getListsList()', ->
#     it 'should return Array length is 1 when the request is sent', ->
#       params =
#         count: 1
#       @twitterClient.getListsList params
#       .then (data) ->
#         assert data.length is 1
#     it 'should return id_str typed String when the request is sent', ->
#       params =
#         count: 1
#       @twitterClient.getListsList params
#       .then (data) ->
#         assert typeof data[0].id_str is 'string'

#   # describe 'getListsStatuses()', ->
#   #   it 'should return id_str typed String when the request is sent', ->
#   #     listName = 'list_test'
#   #     params =
#   #       name: listName
#   #     @twitterClient.createLists params
#   #     .then (data) ->
#   #       console.log data
#   #       assert typeof data.name is 'string'
#   #       assert data.name is listName
#   #     .then (data) ->


#   # describe 'getFavLists()', ->
#   #   it 'should return Array length is 1 when the request is sent', ->
#   #     params =
#   #       count: 5
#   #     @twitterClient.getFavLists params
#   #     .then (data) ->
#   #       assert data.length is 5
#   #   it 'should return id_str typed String when the request is sent', ->
#   #     params =
#   #       count: 1
#   #     @twitterClient.getFavLists params
#   #     .then (data) ->
#   #       assert typeof data[0].id_str is 'string'


#   # describe 'createLists() getListsMembers() destroyList()', ->
#   #   it 'should return 1 when the request is sent', ->
#   #     params =
#   #       count: 1
#   #     @twitterClient.getListsList params
#   #     .then (data) ->
#   #       assert data.length is 1
#   #   it 'should return id_str typed String when the request is sent', ->
#   #     params =
#   #       count: 1
#   #     @twitterClient.getListsList params
#   #     .then (data) ->
#   #       assert typeof data[0].id_str is 'string'
