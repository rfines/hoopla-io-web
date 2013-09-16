Controller = require 'controllers/base/postLoginController'
Event = require 'models/event'
PromoRequest = require 'models/promotionRequest'
module.exports = class EventController extends Controller
  list: (params) ->
    EventList = require 'views/event/list'
    console.log params
    Chaplin.datastore.loadEssential 
      success: =>
        @view = new EventList
          region: 'main'
          collection : Chaplin.datastore.event
          filterer: (item, index) ->
            item.nextOccurrence() and item.nextOccurrence().isAfter(moment())
          params:params                
            

  past: ->
    EventList = require 'views/event/list'
    Chaplin.datastore.loadEssential 
      success: =>
        @view = new EventList
          region: 'main'
          collection : Chaplin.datastore.event
          filterer: (item, index) ->
            not item.nextOccurrence() or item.nextOccurrence().isBefore(moment())  
                
  promote: (params) ->
    console.log "params"
    console.log params
    CreatePromotionRequest = require 'views/event/createPromotionRequest'
    Chaplin.datastore.loadEssential
      success: =>
        prRequest = new PromoRequest()
        @view = new CreatePromotionRequest
          region: 'main'
          model: prRequest
          data: Chaplin.datastore.event.get(params.id)
