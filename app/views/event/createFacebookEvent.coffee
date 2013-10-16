View = require 'views/base/view'
Event = require 'models/event'
AddressView = require 'views/address'
PromotionRequest = require 'models/promotionRequest'
FacebookPagesView = require 'views/event/facebookPages'


module.exports = class CreateFacebookEventView extends View
  model:Event
  template: require 'templates/event/createFacebookEvent'
  className: 'create-facebook-event'
  business = {}
  promotionTarget = {}
  promotionRequest = {}
  fbPages = []

  events: 
    "change .pageSelection": "setImage"

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
    td.eventTitle =@model.get('name')
    if @model.get('name').length >74
      td.eventTitle = @textCutter(70,@model.get('name'))
    td

  attach:()->
    super()
    setTimeout(()=>
      @subview('event-address', new AddressView({container : @$el.find('#map'), model : @model}))
      $('input.address').remove()
      $('label[for=address]').remove() 
    ,100) 
    
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
          @setImage()
        error:(err)=>
          return null

  setImage: (data) ->
    x = _.find @fbPages, (item) =>
      item.id is @$el.find('.pageSelection option:selected').val()
    if not x
      x = @fbPages?[0]
    $.ajax
      url: "https://graph.facebook.com/#{x.id}/?fields=cover"
      type: 'GET'
      success: (response, body) =>
        if response?.cover?.source
          $('.event-page-preview img').attr('src', response?.cover?.source)
        else
          $('.event-page-preview img').attr('src', "https://graph.facebook.com/#{x.id}/picture?type=normal")
      error: =>
        $('.event-page-preview img').attr('src', "https://graph.facebook.com/#{x.id}/picture?type=normal")

  textCutter : (i, text) ->
    short = text.substr(0, i)
    return short.replace(/\s+\S*$/, "")  if /^\S/.test(text.substr(i))
    short