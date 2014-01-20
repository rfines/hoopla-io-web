View = require 'views/base/view'
Event = require 'models/event'
AddressView = require 'views/address'
PromotionRequest = require 'models/promotionRequest'
FacebookPagesView = require 'views/event/facebookPages'


module.exports = class CreateFacebookEventView extends View
  template: require 'templates/event/createFacebookEvent'
  className: 'create-facebook-event'
  business : {}
  promotionTarget : {}
  promotionRequest :{}
  fbPages :[]
  dashboard :false

  events: 
    "click .createFbEventBtn":"saveFbEvent"
    
  initialize:(options)=>
    super(options)
    if options and options.options
      @model = options.options.event
      if options.options.edit is true 
        @dashboard = true
      else
        @dashboard = false

      @business = options.options.business
      @promotionTarget = options.options.promotionTarget

    
  getTemplateData: ()->
    td = super()
    td.showFormControls = @dashboard
    if @model.get('media')?.length > 0
      td.coverPhoto = @model.get('media')[0].url
    else
      td.coverPhoto = "client/images/image-placeholder-bg.png"
    td.profileName = @promotionTarget.profileName
    td.eventAddress = @model.get('location').address
    td.defaultLink = @model.get('website') ? @model.get('ticketUrl')
    console.log @model
    if @model.has('nextOccurrence')
      td.dayOfWeek = moment(@model.get('nextOccurrence').start).utc().format('dddd')
      td.time = moment(@model.get('nextOccurrence').start).utc().format("h:mm a")
    else if @model.getStartDate()
      td.dayOfWeek  = moment(@model.getStartDate()).utc().format('dddd')
      td.time = moment(@model.getStartDate()).utc().format("h:mm a")
    else
      td.dayOfWeek = moment(@model.get("startDate")).utc().format("dddd")
      td.time = moment(@model.get('startTime')).utc().format("h:mm a")
    if @model.get('name').length >74
      td.eventTitle = @textCutter(70,@model.get('name'))
    else
      td.eventTitle =@model.get('name')
    td

  attach:()->
    super()
    @subscribeEvent "tab:visible", @initMap
    @subscribeEvent "facebook:publishEvent",@postEvent
    @getFacebookPages(@promotionTarget)
    @setDescription()
  setDescription:()=>
    $('.event-description').html(@model.get('description'))
  getFacebookPages:(promoTarget)=>
    if Chaplin.datastore.facebookPages.length > 0
      @fbPages = Chaplin.datastore.facebookPages
      options=
        business : @business
        event: @model
        pages:@fbPages
      @subview("facebookEventPages", new FacebookPagesView({model: @model, container : @$el.find('.event-pages'), options:options}))
    else if promoTarget.accessToken
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
            event: @model
            pages:@fbPages
          @subview("facebookEventPages", new FacebookPagesView({model: @model, container : @$el.find('.event-pages'), options:options}))

        error:(err)=>
          return null

  textCutter : (i, text) ->
    short = text.substr(0, i)
    return short.replace(/\s+\S*$/, "")  if /^\S/.test(text.substr(i))
    short

  saveFbEvent:(e)=>
    e.preventDefault()
    Chaplin.mediator.publish 'startWaiting'
    console.log @subview('facebookEventPages').getSelectedPage()
    page= @subview('facebookEventPages').getSelectedPage()
    @pageAccessToken = _.find(@fbPages, (item)=>
      return item.id is page
      )?.access_token
    at = @promotionTarget.accessToken
    if @pageAccessToken
      at = @pageAccessToken
    date = moment().toDate().toISOString()
    link = "http://localruckus.com/events/#{@model.id}"
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
      caption:@stripHtml(@model.get('description'))
      title: name
      startTime: moment(@model.nextOccurrence()).toDate().toISOString()
      promotionTime: date
      location: @model.get('location').address
      pageId:page
      ticket_uri: @model.get('ticketUrl')
      pageAccessToken: @pageAccessToken
      promotionTarget: @promotionTarget._id
      media: @model.get('media')?[0]?._id
    pr.eventId = @model.id
    pr.save {},{
      success: (mod, response, options)=>
        @$el.find('.createFbEventButton').attr('disabled',true)
        @publishEvent "facebook:eventCreated", mod
        Chaplin.mediator.publish 'stopWaiting'
        @$el.find('.createFbEventBtn').addClass('disabled')
        @$el.find('.createFbEventBtn').attr('disabled', true)
      error: (mod, xhr, options)->
        @publishEvent "facebook:eventFailed", mod
        Chaplin.mediator.publish 'stopWaiting'
      }
  saveFbEventNoForm:(page, cb)=>
    page=page
    @pageAccessToken = _.find(@fbPages, (item)=>
      return item.id is page
      )?.access_token
    at = @promotionTarget.accessToken
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
      caption:@stripHtml(@event.get('description'))
      title: name
      startTime: moment(@event.get("startDate")).toDate().toISOString()
      promotionTime: date
      location: @event.get('location').address
      pageId:page
      ticket_uri: @event.get('ticketUrl')
      pageAccessToken: @pageAccessToken
      promotionTarget: @promotionTarget._id
      media: @event.get('media')?[0]?._id
    pr.eventId = @event.id
    pr.save {},{
      success: (mod, response, options)=>
        Chaplin.mediator.publish 'stopWaiting'
        cb null,mod
      error: (mod, xhr, options)->
        Chaplin.mediator.publish 'stopWaiting'
        cb xhr, mod
      }
  postEvent:(data)=>
    page = data.pageId
    @event = data.event
    @model = @event
    @saveFbEventNoForm page, data.callback

  stripHtml:(text)=>
    regex = /(<([^>]+)>)/ig
    text.replace(regex, "")
    text

  initMap:()=>
    if !@subview 'event-address'
      setTimeout(()=>
        @subview('event-address', new AddressView({container : @$el.find('#map'), model : @model}))
        $('input.address').remove()
        $('label[for=address]').remove() 
      , 500)