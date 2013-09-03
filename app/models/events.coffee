Collection = require 'models/base/collection'
Event = require('models/event')

module.exports = class Events extends Collection
  model : Events
  url: ->
    "/api/user/#{$.cookie('user')}/events"
  
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
    