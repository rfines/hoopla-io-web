Businesses = require 'models/businesses'
Business = require 'models/business'
Events = require 'models/events'
Event = require 'models/event'
Media = require 'models/media'
Medias = require 'models/medias'

module.exports = exports = class DataStore

  business : new Businesses()
  event : new Events()
  media : new Medias()

  constructor: (@name) ->
    @event.model = Event
    @business.model = Business
    @media.model = Media

  load: (options) ->
    if @["#{options.name}"].length > 0
      options.success()
    else
      @["#{options.name}"].fetch
        success: =>
          options.success()

  loadEssential: (options) ->
    Chaplin.mediator.publish 'startWaiting'
    Chaplin.datastore.load 
      name : 'business'
      success: =>
        Chaplin.datastore.load 
          name : 'event'
          success: =>
            Chaplin.datastore.load 
              name : 'media'
              success: =>
                Chaplin.mediator.publish 'stopWaiting'
                options.success()
              error: =>
                options.error() if options.error
          error: =>
            options.error() if options.error
      error: =>
        options.error() if options.error                            
