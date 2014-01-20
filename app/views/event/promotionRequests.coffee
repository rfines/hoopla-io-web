ListView = require 'views/base/list'
template = require 'templates/event/promotionRequests'
ListItem = require 'views/event/promotionRequest'
Event = require 'models/event'


module.exports = class PromotionRequestList extends ListView
  className: 'promotion-request-list'
  template: template
  itemView: ListItem
  noun : 'promotionRequest'
  listSelector : '.promotions-container'
  business : undefined
  postType:""
  pushType : "FACEBOOK-POST"
  past : false
  event: undefined
  initialize:(options)=>
    super(options)
    if options.postType
      @postType=options.postType
    if options.past
      @past = options.past
    if options.pushType
      @pushType = options.pushType
    if options.event
      @event = options.event
    @collection.on('add', @render, this)
    @collection.on('reset', @render, this)
    @collection.on('delete', @render, this)
  attach:()=>
    @subscribeEvent "twitter:tweetCreated", @addModel
    @subscribeEvent "facebook:eventCreated", @addModel
    @subscribeEvent "facebook:postCreated", @addModel
    @subscribeEvent "getSelectedEvent", @sendEvent
    super
  
  getTemplateData:()=>
    td = super()
    if @collection?.length > 0
      td.posts = true
    else
      td.posts = false
      td.emptyState = "You haven't created a #{@postType} yet. Creating a Facebook Event page can significantly improves your promotional efforts so we've generated a preview below, you may create one now if you'd like. "
    if @collection.length >0 and @pushType is "FACEBOOK-EVENT"
      td.isEvent = true
      $('.createFbEventBtn').attr('disabled', true)
    td.eventId = @event.id
    td

  sendEvent:(cb)=>
    if @event
      cb @event

  addModel:(mod)=>
    if mod and mod.get('pushType') is @pushType
      if moment(mod.get('promotionTime')).isBefore(moment()) is false and @past is false
        console.log "Adding to future collection for #{@pushType}"
        @collection.add mod
        @publishEvent "#{mod.get('pushType')}:#{@past}", @collection.models.length
      else if moment(mod.get('promotionTime')).isBefore(moment()) is true and @past is true
        console.log "Adding to past collection for #{@pushType}"
        @collection.add mod
        @publishEvent "#{mod.get('pushType')}:#{@past}", @collection.models.length
