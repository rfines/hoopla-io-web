ListView = require 'views/base/list'
template = require 'templates/event/list'
ListItem = require 'views/event/listItem'
Event = require 'models/event'

module.exports = class List extends ListView
  className: 'event-list'
  template: template
  itemView: ListItem
  noun : 'event'
  listSelector : '#accordion'
  listRoute : 'myEvents'
  
  initialize: (options) ->
    super(options)

  filterer: (item, index) ->
    index < 20

  attach: ->
    super()
    @delegate('click', '.showMoreButton', @showMore)
    @filter @filterer

  showMore: =>
    @publishEvent '!router:route', '/myEvents/more'

  create: (e) =>
    EventEdit = require 'views/event/edit'
    newEvent = new Event()
    if Chaplin.datastore.business.hasOne()
      newEvent.set 
        'business' : Chaplin.datastore.business.first().id
        'host' : Chaplin.datastore.business.first().id
        'location' : Chaplin.datastore.business.first().get('location')          
    new EventEdit
      container: @$el.find('.newEvent')
      collection : Chaplin.datastore.event
      model : newEvent    