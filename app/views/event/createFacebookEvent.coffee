View = require 'views/base/view'
Event = require 'models/event'
AddressView = require 'views/address'
PromotionRequest = require 'models/promotionRequest'
FacebookPagesView = require 'views/event/facebookPages'


module.exports = class CreateFacebookEventView extends View
  model:Event
  template: require 'templates/event/createFacebookEvent'
  autoRender: true
  className: 'create-facebook-event'
  business = {}
  promotionTarget = {}
  promotionRequest = {}
  fbPages = []
  initialize:(options)=>
    super(options)
    @business = options.options.business
    @promotionTarget = options.options.promotionTarget
    
  getTemplateData: ()->
    td = super()
    td.profileImgUrl = @promotionTarget.profileImageUrl
    td.profileName = @promotionTarget.profileName
    td.eventAddress = @model.get('location').address
    td.defaultLink = @model.get('website')
    td.coverPhoto = @promotionTarget.profileCoverPhoto
    td.dayOfWeek = moment(@model.nextOccurrence()).format("dddd")
    td.startDate = moment(@model.nextOccurrence()).format("h:mm a")
    td

  attach:()->
    super()
    @subview('event-address', new AddressView({container : @$el.find('.event-map'), model : @model}))  
    $('input.address').remove()
    $('label[for=address]').remove()
    @getFacebookPages(@promotionTarget)

  getFacebookPages:(promoTarget)=>
    if promoTarget.accessToken
      pageUrl= "https://graph.facebook.com/#{promoTarget.profileId}/accounts?access_token=#{promoTarget.accessToken}"
      $.ajax
        url:pageUrl
        type:'GET'
        success:(response,body )=>
          @fbPages = response.data
          @fbPages.push({
            id:promoTarget.profileId
            name: promoTarget.profileName
          })
          options=
            business : @business
            event: @event
            pages:@fbPages
          @subview("facebookEventPages", new FacebookPagesView({model: @model, container : @$el.find('.event-pages'), options:options}))
        error:(err)=>
          return null