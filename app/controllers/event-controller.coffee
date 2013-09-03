Controller = require 'controllers/base/postLoginController'
Event = require 'models/event'

module.exports = class EventController extends Controller
  create: ->
    EventEdit = require 'views/event/edit'
    Chaplin.datastore.loadEssential 
      success: =>    
        newEvent = new Event()
        if Chaplin.datastore.business.hasOne()
          newEvent.set 
            'business' : Chaplin.datastore.business.first().id
            'host' : Chaplin.datastore.business.first().id
            'location' : Chaplin.datastore.business.first().get('location')          
        @view = new EventEdit
          region: 'main'
          collection : Chaplin.datastore.event
          model : newEvent
        @stopWaiting()

  edit: (params) ->
    EventEdit = require 'views/event/edit'
    Chaplin.datastore.loadEssential 
      success: =>
        @view = new EventEdit
          region: 'main'
          collection : Chaplin.datastore.event
          model : Chaplin.datastore.event.get(params.id)

  list: (params) ->
    EventList = require 'views/event/list'
    Chaplin.datastore.loadEssential 
      success: =>
        @view = new EventList
          region: 'main'
          collection : Chaplin.datastore.event.upcomingEvents(10)

  more: (params) ->
    EventList = require 'views/event/list'
    Chaplin.datastore.loadEssential 
      success: =>
        @view = new EventList
          region: 'main'
          collection : Chaplin.datastore.event.upcomingEvents()          

  past: ->
    EventList = require 'views/event/list'
    Chaplin.datastore.loadEssential 
      success: =>
        @view = new EventList
          region: 'main'
          collection : Chaplin.datastore.event.pastEvents(10)
