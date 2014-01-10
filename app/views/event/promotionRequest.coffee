ListItemView = require 'views/base/listItem'
PromotionRequest = require 'models/promotionRequest'

module.exports = class PromotionRequestListItem extends ListItemView
  template: require 'templates/event/promotionRequest'
  noun : "promotionRequest"
  model: PromotionRequest
 
  initialize:(options)=>
    super(options)

  getTemplateData:()=>
    td = super()
    if @model.get('media')?.length >0
      td.imageUrl = @model.get('media')[0].url
    else
      td.imageUrl = "http://placehold.it/100x100"
    console.log @model
    if @model.get('pageId') is @model.get("promotionTarget")?.profileId
      td.handle = @model.get("promotionTarget")?.profileName
    else
      if Chaplin.datastore.facebookPages?.length >0
        fbp = _.find Chaplin.datastore.facebookPages, (item)=>
          return item.id is @model.get('pageId')
        handle = fbp.name if fbp
    if @model.get('pushType') is 'FACEBOOK-EVENT'
      td.isPost = false
      postId = @model.get('status').postId 
      td.postUrl = "https://www.facebook.com/events/#{postId}"
    else
      if@model.get('pushType') is 'TWITTER-POST'
        td.postUrl = "https://twitter.com/#{td.handle}"
        twitterTarget = _.filter @model.get('promotionTarget'), (item)=>
          return item.accountType is 'TWITTER'
        if twitterTarget and twitterTarget.profileImageUrl
          td.imageUrl = twitterTarget.profileImageUrl
        else
          td.imageUrl = undefined
      else
        pageId =@model.get('pageId') 
        td.postUrl = "https://www.facebook.com/#{pageId}"
      td.isPost = true
    if @model.get('promotionTime') and moment(@model.get('promotionTime')).isBefore(moment())
      td.formattedTime = moment(@model.get('status').completedDate).calendar()
      td.past = true
    else
      td.formattedTime = moment(@model.get('promotionTime')).calendar()

    td
  attach:()=>
    super()
 