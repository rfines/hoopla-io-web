Controller = require 'controllers/base/postLoginController'
Event = require 'models/event'
PromoRequest = require 'models/promotionRequest'
module.exports = class EventController extends Controller
  list: (params) ->
    if Chaplin.datastore.user
      EventList = require 'views/event/list'
      Chaplin.datastore.loadEssential 
        success: =>
          @view = new EventList
            region: 'main'
            collection : Chaplin.datastore.event
            params:params
            timeFilter: 'future'                

  past: ->
    EventList = require 'views/event/list'
    Chaplin.datastore.loadEssential 
      success: =>
        collection = Chaplin.datastore.event
        collection.reset(collection.sortBy(@pastComparator))
        @view = new EventList
          region: 'main'
          collection : collection
          filterer: (item, index) ->
            not item.nextOccurrence() or item.nextOccurrence().isBefore(moment())
          timeFilter: 'past'  
                
  promote: (params) ->
    CreatePromotionRequest = require 'views/event/createPromotionRequest'
    Chaplin.datastore.loadEssential
      success: =>
        prRequest = new PromoRequest()
        @view = new CreatePromotionRequest
          region: 'main'
          model: prRequest
          data: Chaplin.datastore.event.get(params.id)

  pastComparator:(event)->
    return -event.lastOccurrence().toDate().getTime()