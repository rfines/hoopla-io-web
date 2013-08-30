Businesses = require 'models/businesses'
Business = require 'models/business'
Events = require 'models/events'
Event = require 'models/event'
Media = require 'models/media'
Medias = require 'models/medias'

module.exports = exports = class DataStore

  constructor: (@name) ->

  business : new Businesses()
  event : new Events()
  media : new Medias()

  load: (options) ->
    @event.model = Event
    if @["#{options.name}"].length > 0
      options.success()
    else if options.user
      @media.model= Media
      @media.fetch
        success: =>
          options.success()
    else
      @["#{options.name}"].fetch
        success: =>
          options.success()
