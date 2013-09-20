View = require 'views/base/view'
PromotionRequest = require 'models/promotionRequest'

module.exports = class FacebookPagesView extends View
  template: require 'templates/event/facebookPages'
  autoRender: true
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