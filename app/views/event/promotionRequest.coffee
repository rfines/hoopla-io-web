ListItemView = require 'views/base/listItem'
PromotionRequest = require 'models/promotionRequest'

module.exports = class PromotionRequestListItem extends ListItemView
  template: require 'templates/event/promotionRequest'
  noun : "promotionRequest"
  event:undefined
  initialize:(options)=>
    super(options)
    @publishEvent 'getSelectedEvent', @getEvent
    
  getTemplateData:()=>
    td = super()
    console.log "Promotion Request gtd"
    console.log @model
    td.buttonText = "View on Facebook"
    if @model.get('media')?.length >0 and @model.get('media')?[0].url
      td.imageUrl = @model.get('media')[0].url
    else if @model.get('media')?.length > 0  and _.isString(@model.get('media')[0])
      td.imageUrl = Chaplin.datastore.media.get(@model.get('media')[0]).get('url')
    else
      td.imageUrl = "http://placehold.it/100x100"
    if @model.attributes.pageId is @model.get("promotionTarget")?.profileId
      td.handle = @model.get("promotionTarget")?.profileName
    else
      if Chaplin.datastore.facebookPages?.length >0
        fbp = _.find Chaplin.datastore.facebookPages, (item)=>
          return item.id is @model.attributes.pageId
        if fbp
          td.handle = fbp.name
        else
          td.handle = @model.get("promotionTarget")?.profileName
    if @model.get('pushType') is 'FACEBOOK-EVENT'
      td.isPost = false
      postId = @model.get('status')?.postId 
      td.postUrl = "https://www.facebook.com/events/#{postId}"
    else
      if@model.get('pushType') is 'TWITTER-POST'
        td.isPost = true
        td.buttonText = "View on Twitter"
        td.postUrl = "https://twitter.com/#{td.handle}/status/#{@model.get('status')?.postId}"
        twitterTarget = undefined
        if _.isArray @model.get('promotionTarget')?
          twitterTarget = _.filter @model.get('promotionTarget'), (item)=>
            return item.accountType is 'TWITTER'
        else if _.isObject @model.get('promotionTarget')
          t = @model.get('promotionTarget')
          if t.accountType is "TWITTER"
            twitterTarget = t
        if twitterTarget and twitterTarget.profileImageUrl
          td.imageUrl = twitterTarget.profileImageUrl
        else
          td.imageUrl = undefined
      else
        pageId =@model.get('pageId') 
        td.postUrl = "https://www.facebook.com/#{pageId}"
      td.isPost = true
    if @model.has('status')
      if @model.get('status').code is 'COMPLETED'
        td.formattedTime = moment(@model.get('status')?.completedDate).calendar()
      else if @model.get('status').code is 'FAILED'
        td.formattedTime = moment(@model.get('promotionTime')).calendar()
        error = @model.get('status').lastError
        if _.isString error
          try
            error = JSON.parse(error)
            td.lastError = error.message
          catch
            td.lastError = error
        else if _.isObject error
          td.lastError = error.message

      else if @model.get('status').code is 'WAITING'
        if @model.get('promotionTime') and moment(@model.get('promotionTime')).isBefore(moment())
          td.formattedTime = moment(@model.get('promotionTime')).calendar()
          td.past = true
          td.future = false
        else
          td.formattedTime = moment(@model.get('promotionTime')).calendar()
          td.past = false
          td.future = true
    td
  attach:()=>
    super()
  events:
    "click .deletePostButton": "destroy"
  destroy: (e) =>
    destroyConfirm = confirm("Delete this Social Media Post")
    if destroyConfirm
      m= @model
      @collection.remove(@model)
      m.destroy()
      @dispose()
  getEvent:(r)=>
    if r 
      @event = r
      @model.set
        eventId: @event.id
      @model.eventId = @event.id
     