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
  initialize:(options)=>
    super(options)
    console.log options
    if options.postType
      @postType=options.postType
    if options.past
      @past = options.past
    if options.pushType
      @pushType = options.pushType

    @collection.on('add', @render(), @)
    @collection.on('reset', @render(), @)
  attach:()=>
    @subscribeEvent "twitter:tweetCreated", @addModel
    @subscribeEvent "facebook:eventCreated", @addModel
    @subscribeEvent "facebook:postCreated", @addModel
    super
  getTemplateData:()=>
    td = super()
    console.log @pushType
    console.log @past
    console.log @postType
    if @collection?.length > 0
      td.posts = true
    else
      td.posts = false
      td.emptyState = "You do not have any #{@postType} to show at this time."
    if @collection.length >0 and @pushType is "FACEBOOK-EVENT"
      td.isEvent = true
    
    td
  addModel:(mod)=>
    console.log mod
    if mod and mod.get('pushType') is @pushType
      if moment(mod.get('promotionTime')).isBefore(moment()) is @past
        @collection.add mod
