ListView = require 'views/base/list'
template = require 'templates/event/list'
ListItem = require 'views/event/listItem'
Event = require 'models/event'
MessageArea = require 'views/messageArea'

module.exports = class List extends ListView
  className: 'event-list'
  template: template
  itemView: ListItem
  noun : 'event'
  listSelector : '#accordion'
  listRoute : 'myEvents'

  attach: ->
    super()
    @subscribeEvent 'closeOthers',=>
      @removeSubview 'newItem' if @subview 'newItem'
      console.log "Should have emptied the new item view"
    @filter @filterer
    @subview('messageArea', new MessageArea({container: '.alert-container'}))
  
  create: (e) =>
    @publishEvent "closeOthers"
    EventEdit = require 'views/event/edit'
    newEvent = new Event()
    @removeSubview('newItem') if @subview('newItem')
    if Chaplin.datastore.business.hasOne()
      newEvent.set 
        'business' : Chaplin.datastore.business.first().id
        'host' : Chaplin.datastore.business.first().id
        'location' : Chaplin.datastore.business.first().get('location')          
    @subview('newItem', new EventEdit({container: @$el.find('.newItem'), collection : Chaplin.datastore.event, model : newEvent}))

  duplicate: (data) =>
    EventEdit = require 'views/event/edit'
    newEvent = data.clone()
    @subview('newItem', new EventEdit({container: @$el.find('.newItem'), collection : Chaplin.datastore.event, model : newEvent}))  