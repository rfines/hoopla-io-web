Model = require 'models/base/model'
ImageUtils = require 'utils/imageUtils'

module.exports = class Event extends Model
  
  urlRoot : "/api/event"

  validate: ->
    errors = []
    if not (@has('name') and @get('name').trim().length > 0)
      errors.push {p : 'name'}
    console.log @attributes
    if not (@has('location') and @get('location').address)
      errors.push {p : 'address'}
    if not (@has('description') and @get('description').trim().length > 0)
      errors.push {p : 'description'}      
    if errors.length is 0
      return undefined
    else
      return errors  

  nextOccurrence: ->
    if @get('occurrences') and _.first(@get('occurrences'))
      m = moment(_.first(@get('occurrences')).start)
      m.local()
      if m.isAfter(moment().startOf('day'))
        return m
    return undefined

  lastOccurrence: ->
    if @get('occurrences') and _.last(@get('occurrences'))
      m = moment(_.last(@get('occurrences')).start)
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
      days = ne.startOf('day').diff(now.startOf('day'), 'days', true)
      if days > 1
        return next.format('MM/DD/YYYY')        
      else
        if days is 0
          return 'Today'
        else
          return 'Tomorrow'
    else
      if @lastOccurrence()
        return @lastOccurrence().format('MM/DD/YYYY')
      else
        return ''

  getStartDate: ->
    return moment(_.first(@get('occurrences')).start)

  getEndDate: ->
    return moment(_.first(@get('occurrences')).end)    

  getSortDate: ->
    return @nextOccurrence() || @lastOccurrence()

  imageUrl: (options) ->
    media = @get('media')
    if media?.length > 0
      return $.cloudinary.url(ImageUtils.getId(media[0].url), {crop: 'fill', height: options.height, width: options.width})  
    else
      return undefined    