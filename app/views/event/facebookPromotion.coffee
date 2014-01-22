View = require 'views/base/view'
PromotionRequest = require 'models/promotionRequest'
FacebookPagesView = require 'views/event/facebookPages'
CreateFacebookEventView = require 'views/event/createFacebookEvent'
AddressView = require 'views/address'
MessageArea = require 'views/messageArea'
module.exports = class FacebookPromotion extends View
  className: 'create-promotion-requests'
  model:PromotionRequest
  event: {}
  business: {}
  location:{}
  template:undefined
  noun: 'promotion'
  facebookImgUrl: undefined
  facebookProfileName : undefined
  fbPromoTarget : undefined
  fbPages : []
  dashboard : false
  defaultLink:""
  edit : false
  nextOccurrence:undefined
  initialize:(options) ->
    super(options)
    if options.template
      @template = options.template
    else
      @template = require('/templates/event/createFacebookPromotionRequest')
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
    @model = new PromotionRequest()
    
  getTemplateData: ->
    td = super()
    td.eventAddress = @location
    if @event.nextOccurrence()
      next = @event.nextOccurrence()
    else
      next = @event.get('startDate')
    @nextOccurrence = moment(next)
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
      td.showPostButtons = false
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
    
    @initDatePickers()
    @initTimePickers()
    @getFacebookPages(@fbPromoTarget) if @fbPromoTarget
    @subscribeEvent "updateFacebookPreview",@updatePreview
    @subscribeEvent "event:promoteFacebook", @promoteFb
    @subscribeEvent "facebookPageChanged",@setImage
    
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
    'keyup .fbCustomLinkBox':'checkLink'
  checkLink:(e)=>
    e.preventDefault() if e
    v = @$el.find('.fbCustomLinkBox').val()
    if v and v.length >= 4
      if v.indexOf('http') is -1
        v = "http://#{v}"
        @$el.find('.fbCustomLinkBox').val(v)
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
    if @event.getStartDate()
      defaultDate = @event.getStartDate().toDate() 
    else
      defaultDate  =moment().toDate()
    @startDate = new Pikaday
      field: @$el.find('.promoDate')[0]
      minDate: moment().toDate()
      format: 'M-DD-YYYY'
      defaultDate: defaultDate
      setDefaultDate:true
    if not @model.isNew()
      startDate.setMoment @event.date
     
  initTimePickers: =>
    if @event.getStartDate()
      defaultDate = @event.getStartDate().toDate() 
    else
      defaultDate  =moment().toDate()
    @$el.find('.startTime').timepicker
      scrollDefaultTime : moment().format("hh:mm a")
      step : 15
    if not @model.isNew()
      @$el.find('.startTime').timepicker('setTime', defaultDate.toDate());
      @$el.find('.promoDate').timepicker('setTime', defaultDate.toDate());

  saveFacebook:(e, cb) =>
    if e
      e.preventDefault()
    if not cb
      Chaplin.mediator.publish 'startWaiting'
    message = @$el.find('.message').val()
    div = $("<div></div>")
    plainText = div.html(@event.get('description')).text()
    caption = "Date: #{@nextOccurrence.format('MMM DD, YYYY')}  Time: #{@nextOccurrence.format('h:mm A')} at #{@event.get('location').address}."
    console.log plainText
    med = @event.get('media')?[0]?._id if @event.has('media') 
    link = "http://www.localruckus.com/event/#{@event.id}"
    if @$el.find('.fb-cusLink-box').is(':checked')
      link = $('.fbCustomLinkBox').val()
      if link.indexOf('http') is -1
        link = "http://#{link}"
    page = @subview('facebookPostPages').getSelectedPage()
    @pageAccessToken = _.find(@fbPages, (item)=>
      return item.id is page
    )
    @pageAccessToken = @pageAccessToken.access_token
    if @$el.find('.fb-immediate-box').is(':checked')
      console.log "Saving immediate facebook post."
      pr = new PromotionRequest
        message: message
        link:link
        caption:caption
        description:plainText
        title: @event.get('name')
        pageId: page
        pageAccessToken:@pageAccessToken
        promotionTime: moment().toDate().toISOString()
        media: med
        promotionTarget: @fbPromoTarget._id
        pushType: 'FACEBOOK-POST'
      pr.eventId = @event.id
      console.log pr
      pr.save {}, {
        success:(item)=>
          Chaplin.mediator.publish 'stopWaiting'
          @publishEvent "notify:postPublish","Success! Your Facebook post will go live within 10 minutes."
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

            @publishEvent "notify:postPublish",{id:@event.id, type:"error",message:"An error occurred while saving your Facebook post." }
      }    
    else if @$el.find('.fb-scheduled-box').is(':checked')
      console.log "Scheduling facebook post" 
      date = @startDate.getMoment()
      t = moment()
      if @$el.find('.startTime').timepicker('getTime')
        t = @$el.find('.startTime').timepicker('getTime')
      time = moment(t).format("hh:mm a")
      date = moment("#{date.format("MM-DD-YYYY")} #{time}", "MM-DD-YYYY hh:mm a")
      d= moment(date).toDate().toISOString()
      scheduled= new PromotionRequest
        message: message
        link:link
        caption:caption
        description:plainText
        title: @event.get('name')
        media: med
        promotionTarget: @fbPromoTarget._id
        pushType: 'FACEBOOK-POST'
        pageId:page
        pageAccessToken: @pageAccessToken
        promotionTime: d
      scheduled.eventId = @event.id
      console.log scheduled
      scheduled.save {}, {
        success:(response,body)=>
          Chaplin.mediator.publish 'stopWaiting'
          @publishEvent "notify:postPublish","Bingo! Your Facebook post will be posted #{moment(date).calendar()}."
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
            @publishEvent "notify:postPublish",{id:@event.id, type:"error",message:"An error occurred while saving your Facebook post." }
      }   
    else 
      Chaplin.mediator.publish 'stopWaiting'
      @publishEvent 'notify:postPublish', {type:'error', message: "When do you want the Facebook magic to happen? Please tell us in the Facebook post tab."}
  setPreviews:(page)=>
    if @$el.is(':visible')
      @setImage({page:page})
  setImage: (data) ->
    x=undefined
    if data and data.page
      x= data.page
    else
      x = _.find @fbPages, (item) =>
        item.id is @subview("facebookPostPages").getSelectedPage()
    if not x
      x = @fbPages?[0]
    $.ajax
      url: "https://graph.facebook.com/#{x.id}/?fields=cover"
      type: 'GET'
      success: (response, body) =>
        if response?.cover?.source
          @$el.find('.facebook-post-preview-img').attr('src', response?.cover?.source)
        else
          @$el.find('.facebook-post-preview-img').attr('src', "https://graph.facebook.com/#{x.id}/picture?type=normal")
        @$el.find('.facebook-post-preview-name').text(x.name)
      error: =>
        @$el.find('.facebook-post-preview-name').text(x.name)
        @$el.find('.facebook-post-preview-img').attr('src', "https://graph.facebook.com/#{x.id}/picture?type=normal")

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
          @setImage({page:_.first(@fbPages)})
          options=
            business : @business
            event: @event
            pages:@fbPages
          container = @$el.find('.pages')
          console.log container
          @subview("facebookPostPages", new FacebookPagesView({model: @model, container : container, options:options}))
        error:(err)=>
          return null
  swapLinks:(e)=>
    v = @$el.find('.fbCustomLinkBox').val()
    if v is not @defaultLink
      @defaultLink = v
      @$el.find(".message").val(replaceLink(@$el.find('.message').val(), @defaultLink, v))
 

  replaceLink:(text, old, newLink)=>
    s = text.split(' ')
    index = s.indexOf(old)
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
    
  validate: (message, immediate, date, time)=>
    valid = true
    if not message or not message.length > 0
      @$el.find('input[type=textarea]').addClass('error')
      valid = false
      @publishEvent 'notify:postPublish', {type:'error', message:"Magic requires words, please enter a message to post!"}
    if not immediate.is(':checked') and time is null and not date._i
      valid = false
      @$el.find('input[type=checkbox]').addClass('error')
      @$el.find('.datePicker').addClass('error')
      @$el.find('.timepicker').addClass('error')
      @publishEvent 'notify:postPublish', {type:'error', message:"When do you want this magic to happen?"}
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