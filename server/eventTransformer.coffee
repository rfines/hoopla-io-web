_ = require('lodash')
moment = require('moment')

nextOccurrence = (event) ->
  if event.occurrences and _.first(event.occurrences)?.start
    m = moment(_.first(event.occurrences).start)
    m.local()
    if m.isAfter(moment().startOf('day'))
      return m
  return undefined

dateDisplayText = (event) ->
  now = moment()
  ne = nextOccurrence(event)
  if ne
    next = ne
    days = ne.startOf('day').diff(now.startOf('day'), 'days', true)
    if days > 1
      return next.format('MM/DD/YYYY')        
    else
      if days is 0
        return 'Today'
      else
        return 'Tomorrow'
  else
    return ''

timeDisplayText = (event) ->
  ne = nextOccurrence(event)
  console.log ne._i
  if ne
    st = moment(ne.start)
    et = moment(ne.end)
    return "#{st.format('hh:mm')} - #{et.format('hh:mm')}"
  else
    return ''

module.exports.transform = (event) ->
  cost = ''
  if event.cost is 0 or not event.cost
    cost = 'FREE'
  else
    cost = "$#{event.cost}"
  return {
    name : event.name
    eventImage : event.media?[0]?.url || 'http://placehold.it/100x100'
    dateDisplay : dateDisplayText(event)
    timeDisplay : timeDisplayText(event)
    cost:cost
    description:event.description || ''
    hostName: event.business.name
    link: event.website

  }