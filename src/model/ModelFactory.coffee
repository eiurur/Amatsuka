path                = require 'path'
ConfigProvider      = require path.resolve 'build', 'model', 'ConfigProvider'
IllustratorProvider = require path.resolve 'build', 'model', 'IllustratorProvider'
PictProvider        = require path.resolve 'build', 'model', 'PictProvider'
UserProvider        = require path.resolve 'build', 'model', 'UserProvider'

cp = new ConfigProvider()
ip = new IllustratorProvider()
pp = new PictProvider()
up = new UserProvider()

module.exports = class ModelFactory
  @create: (name) ->
    switch name.toLowerCase()
      when 'config' then return cp
      when 'illustrator' then return ip
      when 'pict' then return pp
      when 'user' then return up
      else return null

# module.exports = class ModelFactory
#   @create: (name) ->
#     switch name.toLowerCase()
#       when 'config' then return new ConfigProvider()
#       when 'illustrator' then return new IllustratorProvider()
#       when 'pict' then return new PictProvider()
#       when 'user' then return new UserProvider()
#       else return null
