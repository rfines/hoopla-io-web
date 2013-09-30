Model = require 'models/base/model'
ImageUtils = require 'utils/imageUtils'

module.exports = class Event extends Model
  
  urlRoot : "/api/event"

  validation :
    name:
      required: true        
    description:
      required: true
    location:
      required: true
    contactPhone:
      required: false
      pattern: "phone"
    cost:
      required: false
      pattern: "number"

  nextOccurrence: ->
    if @get('occurrences') and _.first(@get('occurrences'))
      m = moment.utc(_.first(@get('occurrences')).start)
      return m
    return undefined

  nextOccurrenceEnd: ->
    if @get('occurrences') and _.first(@get('occurrences'))
      m = moment.utc(_.first(@get('occurrences')).end)
      return m
    return undefined

  lastOccurrence: ->
    if @get('occurrences') and _.last(@get('occurrences'))
      m = moment(_.last(@get('occurrences')).start)
      return m
    else if @get('fixedOccurrences') and _.last(@get('fixedOccurrences'))
      m = moment(_.last(@get('fixedOccurrences')).end)
      return m   
    else if @get('schedules') and @get('schedules').length > 0
      m = moment(_.first(@get('schedules')).end)
      return m
    return undefined 

  dateDisplayText: ->
    now = moment.utc()
    ne = @nextOccurrence()
    if ne
      next = ne
      days = ne.startOf('day').diff(now.startOf('day'), 'days', true)
      if days > 1
        return next.format('MM/DD/YYYY')        
      else
        if days < 1
          return 'Today'
        else if days is 1
          return 'Tomorrow'
        else
          return @nextOccurrence().format('MM/DD/YYYY') || moment(@endDate).format('MM/DD/YYYY') || moment(@startDate).format('MM/DD/YYYY')
    else
      console.log 'getting last occurrence'
      if @lastOccurrence()
        return @lastOccurrence().format('MM/DD/YYYY')
      else
        return ''

  getStartDate: ->
    if @get('occurrences')?.length > 0
      return moment.utc(_.first(@get('occurrences')).start)
    else
      if @get('schedules')?[0]
        return moment.utc(@get('schedules')[0].start)
      else
        return undefined

  getEventStartDate: ->
    if @get('schedules')?[0]
      return moment.utc(@get('schedules')[0].start)
    else
      if @get('occurrences')?.length > 0
        return moment.utc(_.first(@get('occurrences')).start)
      else
        return undefined        

  getEndDate: ->
    if @get('occurrences')?.length > 0
      return moment(_.first(@get('occurrences')).end)
    else
      if @get('schedules')?[0]
        return moment(@get('schedules')[0].end)
      else
        return undefined  

  getSortDate: ->
    return @nextOccurrence() || @lastOccurrence()

  imageUrl: (options) ->
    media = @get('media')
    if media?.length > 0
      return $.cloudinary.url(ImageUtils.getId(media[0].url), {crop: 'fill', height: options.height, width: options.width})  
    else
      return undefined 

  clone: ->
    json = @toJSON()
    delete json.id
    delete json._id
    delete json._v
    delete json.occurrences
    delete json.fixedOccurrences
    delete json.schedules
    return new Event(json)