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

      console.log 'amatsukaList = ', amatsukaList.id_str

      twitterClient.getListsShow(listIdStr: amatsukaList.id_str)
    .then (list) ->
      console.log '\ngetListsShow list.id_str -> ', list.id_str

      twitterClient.destroyLists(listIdStr: list.id_str)
    .then (data) ->
      console.log '\ndestroyLists data.id_str -> ', data.id_str

      # time = my.formatX()
      twitterClient.createLists( name: "Amatsuka", mode: 'private')
    .then (list) ->
      console.log '\ncreateLists lists -> ', list.id_str

      twitterClient.createListsMembers(listIdStr: list.id_str, twitterIdStr: '2686409167')
    .then (data) ->
      console.log '\ncreateMemberList data -> ', data.id_str

      twitterClient.getListsMembers(listIdStr: data.id_str)
    .then (members) ->
      console.log '\ngetListsMembers members.users[0].screen_name -> ',
        members.users[0].screen_name

      return resolve members

    .catch (err) ->
      console.log 'twitter test err =======> ', err
      return reject err
