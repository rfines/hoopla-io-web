Model = require 'models/base/model'

module.exports = class Event extends Model
  
  urlRoot : "/api/event"

  nextOccurrence: ->
    if @get('occurrences') and _.first(@get('occurrences'))
      m = moment(_.first(@get('occurrences')))
      m.local()
      if m.isAfter(moment().startOf('day'))
        return m
    return undefined

  lastOccurrence: ->
    if @get('occurrences') and _.last(@get('occurrences'))
      m = moment(_.last(@get('occurrences')))
      m.local()
      return m
    else if @get('fixedOccurrences') and _.last(@get('fixedOccurrences'))
      m = moment(_.last(@get('fixedOccurrences')).end)
      m.local()
      return m   
    else if @get('schedules') and @get('schedules').length > 0
      m = moment(_.first(@get('schedules')).end)
      m.local()
      return m
    return undefined 

  dateDisplayText: ->
    now = moment()
    ne = @nextOccurrence()
    if ne
      next = ne
      days = ne.diff(now, 'days', true)
      if days >  2
        return next.format('MM/DD/YYYY')
      else
        if now.days() is next.days()
          return 'Today'
        else
          return 'Tomorrow'
    else
      if @lastOccurrence()
        return @lastOccurrence().format('MM/DD/YYYY')
      else
        return ''

  getStartDate: ->
    return moment(_.first(@get('fixedOccurrences')).start)

  getEndDate: ->
    return moment(_.first(@get('fixedOccurrences')).end)    