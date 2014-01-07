View = require 'views/base/view'
PromotionRequest = require 'models/promotionRequest'
FacebookPagesView = require 'views/event/facebookPages'
CreateFacebookEventView = require 'views/event/createFacebookEvent'
AddressView = require 'views/address'
MessageArea = require 'views/messageArea'

module.exports = class FacebookPromotion extends View
  template: require 'templates/event/createFacebookPromotionRequest'
  className: 'create-promotion-requests'
  event: {}
  business: {}
  location:{}
  noun: 'promotion'
  facebookImgUrl= undefined
  facebookProfileName = undefined
  fbPromoTarget = undefined
  fbPages = []

  initialize:(options) ->
    super(options)
    @event = options.data
    @business = Chaplin.datastore.business.get(@event.get('business'))
    @fbPromoTarget = _.find(@business.attributes.promotionTargets, (item) =>
      return item.accountType is 'FACEBOOK'
      )
    if @event.get('business') is @event.get('host')
      @location = @business.get('location')?.address
    else
      @location = Chaplin.datastore.business.get(@event.get('host')?)?.get('location')?.address
    @facebookImgUrl = @fbPromoTarget?.profileImageUrl
    @facebookProfileName = @fbPromoTarget?.profileName
    @subscribeEvent "notify:publish", @showCreatedMessage if @showCreatedMessage
    @model = new PromotionRequest()
    
  getTemplateData: ->
    td = super()
    td.eventAddress = @location
    if @event.nextOccurrence()
      next = @event.nextOccurrence()
    else
      next = @event.get('startDate')
    td.dayOfWeek = moment(next).format("dddd")
    td.startDate = moment(next).format("h:mm a")
    td.fbPages= @fbPages
    bName = Chaplin.datastore.business.get(@event.get('business'))
    l = ""
    if @event.get('website')
      l = @event.get("website")
    else if @event.get("ticketUrl")
      l = @event.get("ticketUrl")
    td.previewText = "#{@event.get('name')} hosted by #{bName?.get('name')} at #{@event.get('location').address}. Check out more details at #{l}"
    td.defaultLink = l
    if not @fbPromoTarget
      td.showFb = false
      callbackUrl = "#{window.baseUrl}callbacks/facebook?businessId=#{@model.business}"
      td.facebookConnectUrl = "https://www.facebook.com/dialog/oauth?client_id=#{window.facebookClientId}&scope=publish_actions,user_events,manage_pages,publish_stream,photo_upload,create_event&redirect_uri=#{encodeURIComponent(callbackUrl)}"
    else
      td.showFb =true
      td.facebookProfileImageUrl = @facebookImgUrl
      td.facebookProfileName = @facebookProfileName
      td.profileImgUrl = @fbPromoTarget?.profileImageUrl
      td.profileName = @fbPromoTarget?.profileName
      td.coverPhoto = @fbPromoTarget?.profileCoverPhoto
    td
  
  attach : ->
    super
    @subview('messageArea', new MessageArea({container: '.alert-container'}))
    @initDatePickers()
    @initTimePickers()
    @getFacebookPages(@fbPromoTarget) if @fbPromoTarget
    @subscribeEvent "updateFacebookPreview",@updatePreview
    @subscribeEvent "event:promoteFacebook", @promoteFb
   
  events: 
    "submit .promoRequestFormFacebook": "saveFacebook"
    "click .facebookPostBtn": "saveFacebook"
    "click .createFbEventBtn":"saveFbEvent"
    "click .cancelBtn":"cancel"
    "change .fb-immediate-box":"immediateClick"
    "change .fb-scheduled-box":"scheduledClick"
    "keyup .message": "updateFacebookPreviewText"
    "click .editPostBtn":"showPostForm"
    "change .fb-cusLink-box": "showLinkBox"
    'change .fb-lrLink-box':"hideLinkBox"

  promoteFb:(data)=>
    @event = data.event
    $('.promoRequestFormFacebook').submit()

  updatePreview:(data)=>
    if data.selector and not data.html
      @$el.find(data.selector).val(data.value)
    else if data.selector and data.html
      @$el.find(data.selector).innerHtml(data.value)
    else if data.key
      @event[data.key] = data.value

  initDatePickers: =>
    @startDate = new Pikaday
      field: @$el.find('.promoDate')[0]
      minDate: moment().toDate()
      format: 'M-DD-YYYY'
    if not @model.isNew()
      startDate.setMoment @model.date
      $('.promoDate').val(@model.date.format('M-DD-YYYY'))
  initTimePickers: =>
    @$el.find('.timepicker').timepicker
      scrollDefaultTime : moment().format("hh:mm a")
      step : 15
    if not @model.isNew()
      @$el.find('.startTime').timepicker('setTime', @model.getStartDate().toDate());
      @$el.find('.endTime').timepicker('setTime', @model.getEndDate().toDate());

  saveFacebook:(e) ->
    e.preventDefault()
    message = $('.message').val()
    successMessageAppend ="" 
    if $('#linkLr').is(':checked')
      link = "http://www.localruckus.com/event/#{@event.id}"
    else if $('#linkCustom').is(':checked')
      link = $('.customLinkBox').val()
    immediate = $('.fb-immediate-box')
    console.log immediate
    date = @startDate.getMoment()
    time = $('.startTime').timepicker('getSecondsFromMidnight')
    date = date.add('seconds', time)
    now = moment().format('X')
    page = $('.pages>.facebook-pages>.pageSelection').val()
    @pageAccessToken = _.find(@fbPages, (item)=>
      return item.id is page).access_token
    
    if immediate.is(':checked')
      pr = new PromotionRequest
        message: message
        link:link
        caption:@event.get('description')
        title: @event.get('name')
        pageId: page
        pageAccessToken:@pageAccessToken
        promotionTime: moment().toDate().toISOString()
        media: @event.get('media')?[0]?._id
        promotionTarget: @fbPromoTarget._id
        pushType: 'FACEBOOK-POST'
      pr.eventId = @event.id
      pr.save {}, {
        success:(item)=>
          Chaplin.mediator.publish 'stopWaiting'
          @publishEvent 'notify:publish', 'Your Facebook event promotion will magically appear shortly.'
          response = {}
          response.fbFinished = true
          @publishEvent 'notify:fbPublished', response

        error:(error)=>
          Chaplin.mediator.publish 'stopWaiting'
          response = {}
          response.fbFinished = false
          response.error = error
          @publishEvent 'notify:fbPublished', response
        
      }    
    else if time? > 0 
      d= moment(date).toDate().toISOString()
      if now >= moment(d).format('X')
        successMessageAppend = "You chose a date or time in the past, your message will go out immediately."
      scheduled= new PromotionRequest
        message: message
        link:link
        caption:@event.get('description')
        title: @event.get('name')
        media: @event.get('media[0]')?._id
        promotionTarget: @fbPromoTarget._id
        pushType: 'FACEBOOK-POST'
        pageId:page
        pageAccessToken: @pageAccessToken
        promotionTime: d
      scheduled.eventId = @event.id
      scheduled.save {}, {
        success:(response,body)=>
          Chaplin.mediator.publish 'stopWaiting'
          @publishEvent 'notify:publish', "Your Facebook event promotion has been scheduled for #{moment(d).format("ddd, MMM D YYYY h:mm A")}. #{successMessageAppend}"
          resp = {}
          resp.fbPublished = true
          @publishEvent 'notify:fbPublished', resp
        error:(error)=>
          Chaplin.mediator.publish 'stopWaiting'
          response = {}
          response.fbPublished = false
          response.error = error
          @publishEvent 'notify:fbPublished', response
      }
    else 
      Chaplin.mediator.publish 'stopWaiting'
      @publishEvent 'notify:publish', {type:'error', message: "When do you want the magic to happen? Please tell us below."}

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
          @subview("facebookPages", new FacebookPagesView({model: @model, container : @$el.find('.pages')[0], options:options}))
        error:(err)=>
          return null

  addCharacter:(e)=>
    code = String.fromCharCode(((if e.keyCode then e.keyCode else e.which)))
    currentPreviewMessage = $('.preview-message').html()
    currentPreviewMessage= currentPreviewMessage + code
    $('.preview-message').html(currentPreviewMessage)

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
    if $('#linkLr').is(':checked')
      link = "http://www.localruckus.com/event/#{@event.id}"
    else if $('#linkCustom').is(':checked')
      link = $('.customLinkBox').val()
    name =@event.get('name')
    if name.length >74
      name = @textCutter(65,name)
    pr = new PromotionRequest
      pushType: "FACEBOOK-EVENT"
      link:link
      caption:@event.get('description')
      title: name
      startTime: moment(@event.nextOccurrence()).toDate().toISOString()
      promotionTime: date
      location: @event.get('location').address
      pageId:page
      ticket_uri: @event.get('ticketUrl')
      pageAccessToken: @pageAccessToken
      promotionTarget: @fbPromoTarget._id
      media: @event.get('media')?[0]?._id
    pr.eventId = @event.id
    pr.save {},{
      success: (model, response, options)=>
        Chaplin.mediator.publish 'stopWaiting'
        @publishEvent 'notify:publish', 'Your event has been successfully created on Facebook. Please allow a few minutes for it to show up.'
      error: (model, xhr, options)->
        Chaplin.mediator.publish 'stopWaiting'
        @publishEvent 'notify:publish', 'Your event has been successfully created on Facebook. Please allow a few minutes for it to show up.'
      }
  
  cancel:(e)->
    e.preventDefault()
    Chaplin.helpers.redirectTo {url: '/myEvents'}

  immediateClick:()->
    element = $('.fb-immediate-box')
    if element.is(':checked')
      @hideFbDates()
    
  scheduledClick:(e)=>
    e.preventDefault() if e
    element = $('.fb-scheduled-box')
    if element.is(':checked')
      @showFbDates()
    else
      @hideFbDates()
      
  hideFbDates:()->
    @$el.find('.inputTimes').hide()

  showFbDates:()->
    @$el.find('.inputTimes').show()

  showCreatedMessage: (data) =>
    $("html, body").animate({ scrollTop: 0 }, "slow");
    if _.isObject(data) and data.type
      @publishEvent 'message:publish', "#{data.type}", "#{data.message}"
    else
      @publishEvent 'message:publish', 'success', "Your #{@noun} has been created. <a href="##{data.id}">View</a>"
    if _.isString(data)
      @publishEvent 'message:publish', 'success', "#{data}"

  validate: (message, immediate, date, time)=>
    valid = true
    if not message or not message.length > 0
      @$el.find('input[type=textarea]').addClass('error')
      valid = false
      @publishEvent 'notify:publish', {type:'error', message:"Magic requires words, please enter a message to post!"}
    if not immediate.is(':checked') and time is null and not date._i
      valid = false
      @$el.find('input[type=checkbox]').addClass('error')
      @$el.find('.datePicker').addClass('error')
      @$el.find('.timepicker').addClass('error')
      @publishEvent 'notify:publish', {type:'error', message:"When do you want this magic to happen?"}
    if valid
      @$el.find('input[type=textarea]').removeClass('error')
      @$el.find('input[type=checkbox]').removeClass('error')
      @$el.find('.datePicker').removeClass('error')
      @$el.find('.timepicker').removeClass('error')
    return valid
  updateFacebookPreviewText:(e)=>
    keyed = @$el.find('.message').val()
    $(".preview-message.fb").html(keyed)
 
  textCutter : (i, text) ->
    short = text.substr(0, i)
    return short.replace(/\s+\S*$/, "")  if /^\S/.test(text.substr(i))
    short
  showPostForm:(e)=>
    if e
      e.preventDefault
    @$el.find('.form_container').slideToggle()
  showLinkBox:(e)=>
    e.preventDefault() if e
    @$el.find(".inputLink").slideDown()
  hideLinkBox:(e)=>
    e.preventDefault() if e
    @$el.find(".inputLink").slideUp()