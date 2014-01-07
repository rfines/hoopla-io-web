View = require 'views/base/view'
Event = require 'models/event'
AddressView = require 'views/address'
PromotionRequest = require 'models/promotionRequest'
FacebookPagesView = require 'views/event/facebookPages'


module.exports = class CreateFacebookEventView extends View
  template: require 'templates/event/createFacebookEvent'
  className: 'create-facebook-event'
  business = {}
  promotionTarget = {}
  promotionRequest = {}
  fbPages = []

  events: 
    "change .pageSelection": "setImage"
    "event:postFacebookEvent":"postEvent"

  initialize:(options)=>
    super(options)
    if options and options.options
      @model = options.options.event
      @business = options.options.business
      @promotionTarget = options.options.promotionTarget
    
  getTemplateData: ()->
    td = super()
    td.profileImgUrl = @promotionTarget.profileImageUrl
    td.profileName = @promotionTarget.profileName
    td.eventAddress = @model.get('location').address
    td.defaultLink = @model.get('website')
    td.coverPhoto = @promotionTarget.profileCoverPhoto
    td.dayOfWeek = moment(@model.get("startDate")).format("dddd")
    td.startDate = moment(@model.get('startDate')).format("h:mm a")
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

  saveFbEvent:(e)=>
    e.preventDefault()
    Chaplin.mediator.publish 'startWaiting'
    page=$('.event-pages>.facebook-pages>.pageSelection').val()
    @pageAccessToken = _.find(@fbPages, (item)=>
      return item.id is page
      )?.access_token
    at = @fbPromoTarget.accessToken
    if @pageAccessToken
      at = @pageAccessToken
    date = moment().toDate().toISOString()
    link = undefined
    if @model.get('website')?.length >0
      link = @model.get('website')
    else if @model.get('ticketUrl')?.length >0
      link = @model.get('ticketUrl')
    name =@model.get('name')
    if name.length >74
      name = @textCutter(65,name)
    pr = new PromotionRequest
      pushType: "FACEBOOK-EVENT"
      link:link
      caption:@model.get('description')
      title: name
      startTime: moment(@event.nextOccurrence()).toDate().toISOString()
      promotionTime: date
      location: @model.get('location').address
      pageId:page
      ticket_uri: @model.get('ticketUrl')
      pageAccessToken: @pageAccessToken
      promotionTarget: @fbPromoTarget._id
      media: @model.get('media')?[0]?._id
    pr.eventId = @model.id
    pr.save {},{
      success: (mod, response, options)=>
        Chaplin.mediator.publish 'stopWaiting'
        @publishEvent 'notify:publish', 'Your event has been successfully created on Facebook. Please allow a few minutes for it to show up.'
      error: (mod, xhr, options)->
        Chaplin.mediator.publish 'stopWaiting'
        @publishEvent 'notify:publish', 'Your event has been successfully created on Facebook. Please allow a few minutes for it to show up.'
      }
  saveFbEventNoForm:(page, id)=>
    Chaplin.mediator.publish 'startWaiting'
    page=page
    @pageAccessToken = _.find(@fbPages, (item)=>
      return item.id is page
      )?.access_token
    at = @fbPromoTarget.accessToken
    if @pageAccessToken
      at = @pageAccessToken
    date = moment().toDate().toISOString()
    link = "http://localruckus.com/event/#{@event.id}"
    if @event.get('website')?.length >0
      link = @event.get('website')
    else if @event.get('ticketUrl')?.length >0
      link = @event.get('ticketUrl')
    name =@event.get('name')
    if name.length >74
      name = @textCutter(65,name)
    pr = new PromotionRequest
      pushType: "FACEBOOK-EVENT"
      link:link
      caption:@event.get('description')
      title: name
      startTime: moment(@event.get("startDate")).toDate().toISOString()
      promotionTime: date
      location: @event.get('location').address
      pageId:page
      ticket_uri: @event.get('ticketUrl')
      pageAccessToken: @pageAccessToken
      promotionTarget: @fbPromoTarget._id
      media: @event.get('media')?[0]?._id
    pr.eventId = @event.id
    pr.save {},{
      success: (mod, response, options)=>
        Chaplin.mediator.publish 'stopWaiting'
        @publishEvent 'notify:publish', 'Your event has been successfully created on Facebook. Please allow a few minutes for it to show up.'
      error: (mod, xhr, options)->
        Chaplin.mediator.publish 'stopWaiting'
        @publishEvent 'notify:publish', 'Your event has been successfully created on Facebook. Please allow a few minutes for it to show up.'
      }
  postEvent:(data)=>
    page = data.pageId
    @event = data.event
    @model = @event
    @saveFbEventNoForm page
