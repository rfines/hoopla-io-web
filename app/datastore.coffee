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
    else
      @["#{options.name}"].fetch
        success: =>
          options.success()

  loadEssential: (options) ->
    EventList = require 'views/event/list'
    Chaplin.datastore.load 
      name : 'business'
      success: =>
        Chaplin.datastore.load 
          name : 'event'
          success: =>
            Chaplin.datastore.load 
              name : 'media'
              success: =>
                options.success()
