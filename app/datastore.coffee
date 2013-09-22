Businesses = require 'models/businesses'
Business = require 'models/business'
Events = require 'models/events'
Event = require 'models/event'
Media = require 'models/media'
Medias = require 'models/medias'
Widgets = require 'models/widgets'
Widget = require 'models/widget'
EventTags = require 'models/eventTags'

module.exports = exports = class DataStore

  business : new Businesses()
  event : new Events()
  media : new Medias()
  widget : new Widgets()
  user: undefined
  eventTag: new EventTags()
  venue : new Businesses()

  constructor: (@name) ->
    @event.model = Event
    @business.model = Business
    @media.model = Media
    @widget.model = Widget
    @venue.model = Business
    @venue.url = ->
      "/api/venues"

  load: (options) ->
    if @["#{options.name}"].models.length > 0
      options.success()
    else
      @["#{options.name}"].fetch
        success: =>
          options.success()

  loadEssential: (options) ->
    Chaplin.mediator.publish 'startWaiting'
    async.parallel [
      (callback) ->
        Chaplin.datastore.load
          name: 'venue'
          success: ->
            callback null
      (callback) ->
        Chaplin.datastore.load
          name: 'business'
          success: ->
            callback null            
      (callback) ->
        Chaplin.datastore.load
          name: 'event'
          success: ->
            callback null
      (callback) ->
        Chaplin.datastore.load
          name: 'media'
          success: ->
            callback null
      (callback) ->
        Chaplin.datastore.load
          name: 'widget'
          success: ->
            callback null
      (callback) ->
        Chaplin.datastore.load
          name: 'eventTag'
          success: ->
            callback null            
    ], ->
      Chaplin.mediator.publish 'stopWaiting'
      options.success()