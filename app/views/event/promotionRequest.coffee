ListItemView = require 'views/base/listItem'
PromotionRequest = require 'models/promotionRequest'

module.exports = class PromotionRequestListItem extends ListItemView
  template: require 'templates/event/promotionRequest'
  noun : "promotion-request"
  model: PromotionRequest
 
  initialize:(options)=>
    super(options)

  getTemplateData:()=>
    td = super()
    console.log @model
    if @model.get('media')?.length >0
      td.imageUrl = @model.get('media')[0].url
    td
  attach:()=>
    super()
