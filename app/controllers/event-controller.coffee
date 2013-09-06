Controller = require 'controllers/base/postLoginController'
Event = require 'models/event'
PromoRequest = require 'models/promotionRequest'
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
<<<<<<< HEAD
          collection : Chaplin.datastore.event
          filterer: (item, index) ->
            not item.nextOccurrence() or item.nextOccurrence().isBefore(moment())      
=======
          collection : Chaplin.datastore.event.pastEvents(10)

  promote: (params) ->
    console.log Chaplin.datastore.event.get(params.id)
    console.log params.id
    CreatePromotionRequest = require 'views/event/createPromotionRequest'
    Chaplin.datastore.loadEssential
      success: =>
        prRequest = new PromoRequest()
        @view = new CreatePromotionRequest
          region: 'main'
          model: prRequest
          data: Chaplin.datastore.event.get(params.id.toString())
          
        
>>>>>>> Promotion request continues
