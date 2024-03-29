_ = require('lodash')
moment = require('moment')

nextOccurrence = (event) ->
  if event.occurrences and _.first(event.occurrences)?.start
    next = _.first(event.occurrences)
    m = moment(next.start)
    e = moment(next.end)
    m.local()
    e.local()
    if m.isAfter(moment().startOf('day'))
      return {start:m,end:e}
  return undefined

dateDisplayText = (event) ->
  now = moment()
  ne = nextOccurrence(event)
  if ne
    next = ne
    days = ne.start.startOf('day').diff(now.startOf('day'), 'days', true)
    if days > 1
      return next.start.format('MM/DD/YYYY')        
    else
      if days is 0
        return 'Today'
      else
        return 'Tomorrow'
  else
    return ''

timeDisplayText = (event) ->
  ne = nextOccurrence(event)
  if ne
    st = moment(ne.start)
    et = moment(ne.end)
    return "#{st.format('h:mm a')} - #{et.format('h:mm a')}"
  else
    return ''

module.exports.transform = (event) ->
  cost = ''
  if event.cost is 0 or not event.cost
    cost = 'FREE'
  else
    cost = "$#{event.cost}"
  o = {
    name : event.name
    eventImage : event.media?[0]?.url || '/client/images/widget-image-placeholder.gif'
    dateDisplay : dateDisplayText(event)
    timeDisplay : timeDisplayText(event)
    cost:cost
    description:event.description || ''
    link: event.website
  }
  o.hostName = event.business.name if event.business
  o.address = event.location.address if event.location?.address
  return o