View = require 'views/base/view'
PromotionRequest = require 'models/promotionRequest'
FacebookPagesView = require 'views/event/facebookPages'
CreateFacebookEventView = require 'views/event/createFacebookEvent'
AddressView = require 'views/address'
MessageArea = require 'views/messageArea'
module.exports = class FacebookPromotion extends View
  className: 'create-promotion-requests'
  event: {}
  business: {}
  location:{}
  noun: 'promotion'
  facebookImgUrl: undefined
  facebookProfileName : undefined
  fbPromoTarget : undefined
  fbPages : []
  dashboard : false
  defaultLink:""
  edit : false

  initialize:(options) ->
    super(options)
    @event = options.data
    if options.edit
      @dashboard = options.edit
      @edit = options.edit 
    @business = Chaplin.datastore.business.get(@event.get('business'))
    @fbPromoTarget = _.find(@business.get('promotionTargets'), (item) =>
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
    td.showFormControls = @dashboard
    td.eventAddress = @location
    if @event.nextOccurrence()
      next = @event.nextOccurrence()
    else
      next = @event.get('startDate')
    td.dayOfWeek = moment(next).format("dddd")
    td.startDate = moment(next).format("h:mm a")
    td.fbPages= @fbPages
    bName = Chaplin.datastore.business.get(@event.get('business'))
    if @event.id
      @defaultLink = "http://localruckus.com/event/#{@event.id}"
    if @event.get('website')
      @defaultLink = @event.get("website")
    else if @event.get("ticketUrl")
      @defaultLink = @event.get("ticketUrl")
    if @edit is false
      td.previewText = "#{@event.get('name')}  hosted by #{Chaplin.datastore.business.get(@event.get('host'))?.get('name')}. "
      if @defaultLink.length > 0
        td.previewText  = td.previewText + "Check out more details at #{@defaultLink}."
    td.defaultLink = @defaultLink

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
    if @edit is true
      @$el.find('.create_buttons').hide()
      @$el.find('.form_container').show()
    @subview('messageArea', new MessageArea({container: '.alert-container'}))
    @initDatePickers()
    @initTimePickers()
    @getFacebookPages(@fbPromoTarget) if @fbPromoTarget
    @subscribeEvent "updateFacebookPreview",@updatePreview
    @subscribeEvent "event:promoteFacebook", @promoteFb
    l = ""
    if @event.get('website')
      l = @event.get("website")
    else if @event.get("ticketUrl")
      l = @event.get("ticketUrl")
    if l.length >0
      $('#linkCustom').attr('checked', true)
      @showLinkBox()
   
  events: 
    "submit .promoRequestFormFacebook": "saveFacebook"
    "click .facebookPostBtn": "saveFacebook"
    "click .cancelBtn":"cancel"
    "change .fb-immediate-box":"immediateClick"
    "change .fb-scheduled-box":"scheduledClick"
    "keyup .message": "updateFacebookPreviewText"
    "click .editPostBtn":"showPostForm"
    "change .fb-cusLink-box": "showLinkBox"
    'change .fb-lrLink-box':"hideLinkBox"
    'blur .fbCustomLinkBox':"swapLinks"

  promoteFb:(data)=>
    @event = data.event
    @saveFacebook undefined,data.callback

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
      defaultDate: @event.getStartDate().toDate()
      setDefaultDate:true
    if not @model.isNew()
      startDate.setMoment @event.date
     
  initTimePickers: =>
    @$el.find('.startTime').timepicker
      scrollDefaultTime : moment().format("hh:mm a")
      step : 15
    if not @model.isNew()
      @$el.find('.startTime').timepicker('setTime', @event.getStartDate().toDate());
      @$el.find('.promoDate').timepicker('setTime', @event.getEndDate().toDate());

  saveFacebook:(e, cb) ->
    if e
      e.preventDefault()
    if not cb
      Chaplin.mediator.publish 'startWaiting'
    message = @$el.find('.message').val()
    successMessageAppend ="" 
    if @$el.find('#linkLr').is(':checked')
      link = "http://www.localruckus.com/event/#{@event.id}"
    else if @$el.find('#linkCustom').is(':checked')
      link = $('.fbCustomLinkBox').val()
    immediate = $('.fb-immediate-box')

    date = @startDate.getMoment()
    time = moment(@$el.find('.startTime').timepicker('getTime')).format("hh:mm a")
    console.log "#{date.format("MM-DD-YYYY")} #{time}"
    date = moment("#{date.format("MM-DD-YYYY")} #{time}")
    now = moment().format('X')

    page = @subview('facebookPages').getSelectedPage()
    @pageAccessToken = _.find(@fbPages, (item)=>
      return item.id is page
    )
    @pageAccessToken = @pageAccessToken.access_token
    if immediate.is(':checked')
      pr = new PromotionRequest
        message: message
        link:link
        caption:@stripHtml(@event.get('description'))
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
          response = {}
          response.fbFinished = true
          if cb
            cb null, response
          else
            @publishEvent "facebook:postCreated", pr
        error:(error)=>
          Chaplin.mediator.publish 'stopWaiting'
          response = {}
          response.fbFinished = false
          response.error = error
          if cb
            cb error, response
          else
            @publishEvent "facebook:postError","An error occurred while saving your Facebook post." 
      }    
    else if time? > 0 
      d= moment(date).toDate().toISOString()
      console.log d
      scheduled= new PromotionRequest
        message: message
        link:link
        caption:@stripHtml(@event.get('description'))
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
          resp = {}
          resp.fbFinished = true
          if cb
            cb null, resp
          else
            @publishEvent "facebook:postCreated", scheduled
        error:(error)=>
          Chaplin.mediator.publish 'stopWaiting'
          response = {}
          response.fbPublished = false
          response.error = error
          if cb
            cb error, response
          else
            @publishEvent "facebook:postError","An error occurred while saving your Facebook post."
      }   
    else 
      Chaplin.mediator.publish 'stopWaiting'
      @publishEvent 'notify:publish', {type:'error', message: "When do you want the Facebook magic to happen? Please tell us in the Facebook post tab."}

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
          Chaplin.datastore.facebookPages = []
          Chaplin.datastore.facebookPages = @fbPages
          @publishEvent "facebook:pagesReady"
          options=
            business : @business
            event: @event
            pages:@fbPages
          @subview("facebookPages", new FacebookPagesView({model: @model, container : @$el.find('.pages')[0], options:options}))
        error:(err)=>
          return null
  swapLinks:(e)=>
    v = @$el.find('.fbCustomLinkBox').val()
    if v is not @defaultLink
      @defaultLink = v
      @$el.find(".message").val(replaceLink(@$el.find('.message').val(), @defaultLink, v))
 

  replaceLink:(text, old, newLink)=>
    s = text.split(' ')
    console.log s
    index = s.indexOf(old)
    console.log index
    if index is -1
      text = "#{text} #{newLink}"
      return text
    else
      s[index] = newLink
      return s.join(' ')

  addCharacter:(e)=>
    code = String.fromCharCode(((if e.keyCode then e.keyCode else e.which)))
    currentPreviewMessage = $('.preview-message').html()
    currentPreviewMessage= currentPreviewMessage + code
    $('.preview-message').html(currentPreviewMessage)
  
  cancel:(e)->
    e.preventDefault()
    Chaplin.helpers.redirectTo {url: '/myEvents'}

  immediateClick:()->
    element = $('.fb-immediate-box')
    if element.is(':checked')
      @hideFbDates()
    else
      @showFbDates()
    
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
  stripHtml:(text)=>
    regex = /(<([^>]+)>)/ig
    text.replace(regex, "")
    text