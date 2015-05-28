TwitterAPI    = require 'node-twitter-api'
TW_CK         = '--YOUR-TWITTER-CONSUMER-KEY--'
TW_CS         = '--YOUR-TWITTER-CONSUMER-SECRET--'
TW_AT         = '--YOUR-TWITTER-ACCESS-TOKEN--'
TW_AS         = '--YOUR-TWITTER-ACCESS-TOKEN-SECRET--'
TW_ID_STR     = '--YOUR-TWITTER-ID-STR--'
CALLBACK_URL  = 'http://127.0.0.1:4040/auth/twitter/callback'
COOKIE_SECRET = 'tw4oiu32ff3wr21toihfsDSfhio324'

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
  MAX_NUM_GET_LISTS_LIST: 100
  MAX_NUM_GET_FAV_TWEET_FROM_LIST: 200
  MAX_NUM_GET_LIST_STATUSES: 200
  MAX_NUM_GET_LIST_MEMBERS: 5000
  twitterAPI: new TwitterAPI
    consumerKey: TW_CK
    consumerSecret: TW_CS
    callback: CALLBACK_URL

  defaultUserIds: '87658369,123720322,124814283,437523928,2228681658'

  targetList: [
    'g1un1u'
    'kamikannda'
    'loliconder'
    'nosongang'
    'sandworks'
    'exit_kureaki'
    'yamayo'
  ]
