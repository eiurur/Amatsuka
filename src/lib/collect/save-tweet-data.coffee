_             = require 'lodash'
{Promise}     = require 'es6-promise'
{my}          = require '../my'
{TLProvider}  = require '../model'
TwitterCilent = require '../TwitterClient'
{settings}    = if process.env.NODE_ENV is "production"
  require '../configs/production'
else
  require '../configs/development'

exports.saveTweetData = (user) ->

  twitterClient = new TwitterCilent(user)


