Controller = require 'controllers/base/postLoginController'
Event = require 'models/event'

module.exports = class EventController extends Controller
  list: (params) ->
    EventList = require 'views/event/list'
    Chaplin.datastore.loadEssential 
      success: =>
        console.log 'list'
        @view = new EventList
          region: 'main'
          collection : Chaplin.datastore.event
          filterer: (item, index) ->
            item.nextOccurrence() and item.nextOccurrence().isAfter(moment())                
            

  past: ->
    EventList = require 'views/event/list'
    Chaplin.datastore.loadEssential 
      success: =>
        @view = new EventList
          region: 'main'
          collection : Chaplin.datastore.event
          filterer: (item, index) ->
            not item.nextOccurrence() or item.nextOccurrence().isBefore(moment())      
