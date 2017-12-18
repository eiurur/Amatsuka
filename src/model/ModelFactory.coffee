path                = require 'path'
ConfigProvider      = require path.resolve 'build', 'model', 'ConfigProvider'
IllustratorProvider = require path.resolve 'build', 'model', 'IllustratorProvider'
PictProvider        = require path.resolve 'build', 'model', 'PictProvider'
UserProvider        = require path.resolve 'build', 'model', 'UserProvider'
RankingProvider      = require path.resolve 'build', 'model', 'RankingProvider'

module.exports = class ModelFactory
  @create: (name) ->
    switch name.toLowerCase()
      when 'config' then return new ConfigProvider()
      when 'illustrator' then return new IllustratorProvider()
      when 'pict' then return new PictProvider()
      when 'user' then return new UserProvider()
      when 'ranking' then return new RankingProvider()
      else return null
