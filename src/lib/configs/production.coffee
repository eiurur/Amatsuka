TwitterAPI   = require 'node-twitter-api'
TW_CK        = process.env.TW_CK
TW_CS        = process.env.TW_CS
TW_AT        = process.env.TW_AT
TW_AS        = process.env.TW_AS
CALLBACK_URL = process.env.CALLBACK_URL
COOKIE_SECRET =  process.env.COOKIE_SECRET

exports.settings =
  TW_CK: TW_CK
  TW_CS: TW_CS
  TW_AT: TW_AT
  TW_AS: TW_AS
  CALLBACK_URL: CALLBACK_URL
  COOKIE_SECRET: COOKIE_SECRET
  GRACE_TIME_SERVER: 0
  GRACE_TIME_CLEAR: 1 * 1000
  INTERVAL_TIME_CLEAR: 10 * 1000
  twitterAPI: new TwitterAPI
    consumerKey: TW_CK
    consumerSecret: TW_CS
    callback: CALLBACK_URL
