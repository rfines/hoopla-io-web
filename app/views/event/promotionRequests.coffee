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
  postType=""
  pushType = "FACEBOOK-POST"
  past = false
  initialze:(options)=>
    super(options)
    if options.postType
      @postType=options.postType
  attach:()=>
    @subscribeEvent "twitter:tweetCreated", @addModel
    @subscribeEvent "facebook:eventCreated", @addModel
    @subscribeEvent "facebook:postCreated", @addModel
    super
  getTemplateData:()=>
    td = super()
    if @collection?.length > 0 and @pushType != "FACEBOOK-EVENT"
      td.posts = true
    else if @collection.length >0 and @pushType is "FACEBOOK-EVENT"
      td.isEvent = true
    else
      td.posts = false
      td.emptyState = "You do not have any #{@postType} to show at this time."
    td
  addModel:(mod)=>
    if mod and mod.get('pushType') is @pushType
      if moment(mod.get('promotionTime')).isBefore(moment()) is @past
        @collection.add mod
