Model = require 'models/base/model'

module.exports = class Event extends Model
  
  urlRoot : "/api/event"

  nextOccurrence: ->
    m = moment(_.first(@get('occurrences')))
    m.local()
    m

  nextOccurrenceText: ->
    now = moment()
    next = @nextOccurrence()
    days = @nextOccurrence().diff(now, 'days', true)
    if days >  2
      return next.format('MM/DD/YYYY')
    else
      if now.days() is next.days()
        return 'Today'
      else
        return 'Tomorrow'

  getStartDate: ->
    return moment(_.first(@get('fixedOccurrences')).start)