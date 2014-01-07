View = require 'views/base/view'
PromotionRequest = require 'models/promotionRequest'
template =  require('templates/event/facebookPages')

module.exports = class FacebookPagesView extends View
  template: template
  className: 'facebook-pages'
  event: {}
  business: {}
  facebookImgUrl= undefined
  facebookProfileName = undefined
  fbPromoTarget = {}
  fbPages = []

  initialize:(options) ->
    super(options)
    @fbPages = options.options.pages
    @pageId = _.first(@fbPages).id
  attach : ->
    super
  getTemplateData : ->
    td = super()
    td.fbPages = @fbPages
    td
    
  events: 
    "change .pageSelection":"setSelectedPage"

  setSelectedPage:(e)=>
    @pageId = $('.pageSelection').val()

  getSelectedPage:=>
    @pageId