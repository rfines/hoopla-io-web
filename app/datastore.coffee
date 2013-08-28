Businesses = require 'models/businesses'
Events = require 'models/events'
Event = require 'models/event'

module.exports = exports = class DataStore

  constructor: (@name) ->

  business : new Businesses()
  event : new Events()

  load: (options) ->
    @event.model = Event
    if @["#{options.name}"].length > 0
      options.success()
    else
      @["#{options.name}"].fetch
        success: =>
          options.success()
