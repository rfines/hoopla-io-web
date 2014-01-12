ListView = require 'views/base/list'
template = require 'templates/event/promotionRequests'
ListItem = require 'views/event/promotionRequest'
Event = require 'models/event'


module.exports = class PromotionRequestList extends ListView
  className: 'promotion-request-list'
  template: template
  itemView: ListItem
  renderItems:true
  noun : 'promotionRequest'
  listSelector : '.promotions-container'
  business : undefined
  postType:""
  pushType : "FACEBOOK-POST"
  past : false
  initialize:(options)=>
    super(options)
    if options.postType
      @postType=options.postType
    if options.past
      @past = options.past
    if options.pushType
      @pushType = options.pushType
    console.log @past
    console.log @pushType
    console.log @container
    @collection.on('add', @render, this)
    @collection.on('reset', @render, this)
  attach:()=>
    @subscribeEvent "twitter:tweetCreated", @addModel
    @subscribeEvent "facebook:eventCreated", @addModel
    @subscribeEvent "facebook:postCreated", @addModel
    super
  getTemplateData:()=>
    td = super()
    console.log @collection.length
    if @collection?.length > 0
      td.posts = true
    else
      td.posts = false
      td.emptyState = "You do not have any #{@postType} to show at this time."
    if @collection.length >0 and @pushType is "FACEBOOK-EVENT"
      td.isEvent = true
      $('.createFbEventBtn').attr('disabled', true)
    
    td
  addModel:(mod)=>
    console.log mod.get('pushType') , @pushType , @past
    if mod and mod.get('pushType') is @pushType
      if moment(mod.get('promotionTime')).isBefore(moment()) is false and @past is false
        console.log "Adding to future collection for #{@pushType}"
        @collection.add mod
        @publishEvent "#{mod.get('pushType')}:#{@past}", @collection.models.length
      else if moment(mod.get('promotionTime')).isBefore(moment()) is true and @past is true
        console.log "Adding to past collection for #{@pushType}"
        @collection.add mod
        @publishEvent "#{mod.get('pushType')}:#{@past}", @collection.models.length