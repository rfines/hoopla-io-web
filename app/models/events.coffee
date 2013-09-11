Collection = require 'models/base/collection'
Event = require('models/event')

module.exports = class Events extends Collection
  model : Events
  url: ->
    "/api/user/#{$.cookie('user')}/events"
    
  comparator : (event) ->
    event.getSortDate().toDate().toISOString()
  
  upcomingEvents: (limit) ->
    c = @filter (item) ->
      item.nextOccurrence() and item.nextOccurrence().isAfter(moment())
    c = _.first(c, 10) if limit
    return new Events(c)

  pastEvents: (limit) ->
    c = @filter (item) ->
      not item.nextOccurrence() or item.nextOccurrence().isBefore(moment())
    c = _.first(c, 10) if limit
    return new Events(c)    
  
  promotionRequests: ()->
    @get 'promotionRequests'

  hasMedia: (mediaId) ->
    @some (item) ->
      if item.has('media')
        return _.some item.get('media'), (i) ->
          i._id is mediaId    
      else
        return false