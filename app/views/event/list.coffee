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
  allowCreate = false

  initialize: (options) ->
    super(options)
    @timeFilter = options.timeFilter

  attach: ->
    super()
    @subview('listMessageArea', new MessageArea({container: '.list-alert.alert-container'})) if not @subview 'listMessageArea'
    @subscribeEvent "notify:publish", @showEventCreatedMessage if @showEventCreatedMessage
    @subscribeEvent 'closeOthers',=>
      @removeSubview 'newItem' if @subview 'newItem'
    @filter @filterer
    baseUrl = window.location.href.split('?')[0].replace "#{window.baseUrl}", ""
    if @params?.error
      Chaplin.mediator.execute('router:changeURL', "#{baseUrl}")
      @publishEvent 'message:publish', 'error', @params.error
    else if @params?.success
      Chaplin.mediator.execute('router:changeURL', "#{baseUrl}")
      @publishEvent 'message:publish', 'success', @params.success
    
    if @timeFilter is 'past' 
      @$el.find('.pastEvents').addClass('btn-info').removeClass('btn-default')
      @$el.find('.futureEvents').addClass('btn-default').removeClass('btn-info')
    else
      @$el.find('.futureEvents').addClass('btn-info').removeClass('btn-default')
      @$el.find('.pastEvents').addClass('btn-default').removeClass('btn-info')    
  
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
    @hideInitialStage()
    @publishEvent "closeOthers"
    EventEdit = require 'views/event/edit'
    EventCreate = require 'views/event/create'
    newEvent = new Event()
    @removeSubview('newItem') if @subview('newItem')
    if Chaplin.datastore.business.hasOne()
      newEvent.set 
        'business' : Chaplin.datastore.business.first().id
        'host' : Chaplin.datastore.business.first().id
        'location' : Chaplin.datastore.business.first().get('location')          
    @subview('newItem', new EventCreate({container: @$el.find('.newItem'), collection : Chaplin.datastore.event, model : newEvent}))

  showEventCreatedMessage: (data) =>
    console.log data
    $("html, body").animate({ scrollTop: 0 }, "slow");
    if _.isObject(data) and data.type
      @publishEvent 'message:publish', "#{data.type}", "#{data.message}"
    else if _.isString(data)
      @publishEvent 'message:publish', 'success', "#{data}"
    else
      @publishEvent 'message:publish', 'success', "Your #{@noun} has been created."

  duplicate: (data) =>
    $("html, body").animate({ scrollTop: 0 }, "slow");
    CreateView = require 'views/event/create'
    newEvent = data.clone()
    @subview('newItem', new CreateView({container: @$el.find('.newItem'), collection : Chaplin.datastore.event, model : newEvent}))  