_             = require 'lodash'
{Promise}     = require 'es6-promise'
{my}          = require './my'
{TLProvider}  = require './model'
TwitterCilent = require './TwitterClient'
{settings}    = if process.env.NODE_ENV is "production"
  require './configs/production'
else
  require './configs/development'

exports.twitterTest = (user) ->

  twitterClient = new TwitterCilent(user)

  return new Promise (resolve, reject) ->
    twitterClient.getHomeTimeline()
    .then (homeTimeline) ->
      console.log '\ngetHomeTimeline homeTimeline -> ', homeTimeline[0]

      twitterClient.getListsList()
    .then (lists) ->
      console.log '\ngetListslsit lists -> ', _.pluck lists, 'name'

      amatsukaList = _.find lists, 'name': 'Amatsuka'

      console.log 'amatsukaList = ', amatsukaList

      twitterClient.getListsShow(listIdStr: amatsukaList.id_str)
    .then (list) ->
      console.log '\ngetListsShow list -> ', list.name

      twitterClient.destroyLists(listIdStr: list.id_str)
    .then (data) ->
      console.log '\ndestroyLists data.length -> ', data

      # time = my.formatX()
      twitterClient.createLists( name: "Amatsuka", mode: 'private')
    .then (list) ->
      console.log '\ncreateLists lists -> ', list

      twitterClient.createMemberList(listIdStr: list.id_str, twitterIdStr: '2686409167')
    .then (data) ->
      console.log '\ncreateMemberList data -> ', data

      twitterClient.getListsMembers(listIdStr: data.id_str)
    .then (members) ->
      console.log '\ngetListsCreate members -> ', members

      return resolve members

    .catch (err) ->
      console.log 'twitter test err =======> ', err
      return reject err
