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
  allowCreate = false

  attach: ->
    super()
    @subscribeEvent 'closeOthers',=>
      @removeSubview 'newItem' if @subview 'newItem'
    @filter @filterer
    if not @allowCreate
      @publishEvent "message:publish", "success", "You need to create a business before you can create events."
    baseUrl = window.location.href.split('?')[0].replace "#{window.baseUrl}", ""
    if @params?.error
      @publishEvent '!router:changeURL',  "#{baseUrl}"
      @publishEvent 'message:publish', 'error', @params.error
    else if @params?.success
      @publishEvent '!router:changeURL',  "#{baseUrl}"
      @publishEvent 'message:publish', 'success', @params.success 
    if location.pathname.split('/').indexOf('past') > -1
      @$el.find('.pastEvents').addClass('active')
      @$el.find('.futureEvents').removeClass('active')
    else
      @$el.find('.pastEvents').removeClass('active')
      @$el.find('.futureEvents').addClass('active')
  
  getTemplateData:->
    td = super()
    if Chaplin.datastore.business.length > 0
      td.allowCreate = true
      @allowCreate = true
    else
      td.allowCreate = false
      @allowCreate = false
    td
  
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