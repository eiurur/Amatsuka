TwitterAPI    = require 'node-twitter-api'
TW_CK         = process.env.TW_CK
TW_CS         = process.env.TW_CS
TW_CS         = process.env.TW_CS
TW_AT         = process.env.TW_AT
TW_AS         = process.env.TW_AS
TW_ID_STR     = process.env.TW_ID_STR
CALLBACK_URL  = process.env.CALLBACK_URL
COOKIE_SECRET = process.env.COOKIE_SECRET

exports.settings =
  TW_CK: TW_CK
  TW_CS: TW_CS
  TW_AT: TW_AT
  TW_AS: TW_AS
  TW_ID_STR: TW_ID_STR
  CALLBACK_URL: CALLBACK_URL
  COOKIE_SECRET: COOKIE_SECRET
  PORT: 4040
  GRACE_TIME_SERVER: 0
  GRACE_TIME_CLEAR: 1 * 1000
  INTERVAL_TIME_CLEAR: 10 * 1000
  FRINEDS_LIST_COUNT: 100
  MAX_NUM_GET_TIMELINE_TWEET: 100
  MAX_NUM_GET_FAV_TWEET_FROM_LIST: 200
  MAX_NUM_GET_LISTS_LIST: 100
  MAX_NUM_GET_LIST_STATUSES: 200
  MAX_NUM_GET_LIST_MEMBERS: 5000
  MAO_TOKEN_SALT: process.env.MAO_TOKEN_SALT
  MAO_HOST: process.env.MAO_HOST
  twitterAPI: new TwitterAPI
    consumerKey: TW_CK
    consumerSecret: TW_CS
    callback: CALLBACK_URL

  defaultUserIds: '87658369,123720322,124814283,437523928,2228681658'

  TWS: [
    {
      TW_STR: TW_ID_STR
      TW_AT: TW_AT
      TW_AS: TW_AS
    }
    {
      TW_ID_STR: TW_ID_STR_2
      TW_AT: process.env.TW_AT_2
      TW_AS: process.env.TW_AS_2
    }
    {
      TW_ID_STR: TW_ID_STR_3
      TW_AT: process.env.TW_AT_3
      TW_AS: process.env.TW_AS_3
    }
    {
      TW_ID_STR: TW_ID_STR_4
      TW_AT: process.env.TW_AT_4
      TW_AS: process.env.TW_AS_4
    }
  ]

  targetList: [
    'g1un1u'
    'kamikannda'
    'loliconder'
    'nosongang'
    'sandworks'
    'exit_kureaki'
    'yamayo'
  ]