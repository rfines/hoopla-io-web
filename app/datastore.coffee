Businesses = require 'models/businesses'
Events = require 'models/events'

module.exports = exports = class DataStore

  constructor: (@name) ->

  business : new Businesses()
  event : new Events()

  load: (options) ->
    if @["#{options.name}"].length > 0
      options.success()
    else
      @["#{options.name}"].fetch
        success: =>
          options.success()
