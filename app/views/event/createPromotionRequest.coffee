View = require 'views/base/view'
PromotionRequest = require 'models/promotionRequest'
FacebookPagesView = require 'views/event/facebookPages'
CreateFacebookEventView = require 'views/event/createFacebookEvent'
AddressView = require 'views/address'
MessageArea = require 'views/messageArea'


module.exports = class CreatePromotionReqeust extends View
  template: require 'templates/event/createPromotionRequest'
  className: 'create-promotion-requests'
  event: {}
  business: {}
  noun: 'promotion'
  facebookImgUrl= undefined
  twitterImgUrl=undefined
  facebookProfileName = undefined
  twitterHandle = undefined
  fbPromoTarget = {}
  twPromoTarget = {}
  fbPages = []

  initialize:(options) ->
    super(options)
    @event = options.data
    @business = Chaplin.datastore.business.get(@event.get('business'))
    @fbPromoTarget = _.find(@business.attributes.promotionTargets, (item) =>
      return item.accountType is 'FACEBOOK'
      )
    @facebookImgUrl = @fbPromoTarget?.profileImageUrl
    @facebookProfileName = @fbPromoTarget?.profileName
    @twPromoTarget =_.find(@business.attributes.promotionTargets, (item) =>
      return item.accountType is 'TWITTER'
      )
    @subscribeEvent "notify:publish", @showCreatedMessage if @showCreatedMessage
    @twitterImgUrl = @twPromoTarget?.profileImageUrl
    @twitterHandle =  @twPromoTarget?.profileName 
    
    
  getTemplateData: ->
    td = super()
    td.facebookProfileImageUrl = @facebookImgUrl
    td.twitterProfileImageUrl = @twitterImgUrl
    td.facebookProfileName = @facebookProfileName
    td.twitterHandle = @twitterHandle
    td.previewText = @event.get('description')
    if not @fbPromoTarget
      td.showFb = false
    else
      td.showFb =true
    if not @twPromoTarget
      td.showTwitter = false
    else
      td.showTwitter = true
    td.profileImgUrl = @fbPromoTarget.profileImageUrl
    td.profileName = @fbPromoTarget.profileName
    td.eventAddress = @event.attributes.location.address
    td.coverPhoto = @fbPromoTarget.profileCoverPhoto
    td.dayOfWeek = moment(@event.nextOccurrence()).format("dddd")
    td.startDate = moment(@event.nextOccurrence()).format("h:mm a")
    td.fbPages= @fbPages
    td
  
  attach : ->
    super
    if @fbPromoTarget
      @showFacebook()
    else
      @showTwitter()
    @subview('messageArea', new MessageArea({container: '.alert-container'}))
    @$el.find('.tweetMessage').simplyCountable({
      maxCount: 140
      strictMax:true
      overClass:'alert alert-error'
      countDirection: 'down'

    })
    
    @initDatePickers()
    @initTimePickers()
    @getFacebookPages(@fbPromoTarget)
   
    

  events: 
    "click .facebookPostBtn": "saveFacebook"
    "submit form.promoRequestFormTwitter" : "saveTwitter"
    "click .createFbEventBtn":"saveFbEvent"
    "click .cancelBtn":"cancel"
    "click .facebookTab" : "showFacebook"
    "click .twitterTab" : "showTwitter"
    "click .facebookEventTab":"showFacebookEvent"
    "change .immediate-box":"immediateClick"
    "change .tw-immediate-box": "twitterImmediateClick"
    
  initDatePickers: =>
    @startDate = new Pikaday
      field: @$el.find('.promoDate')[0]
      minDate: moment().toDate()
      format: 'M-DD-YYYY'
    if not @model.isNew()
      startDate.setMoment @model.date
      $('.promoDate').val(@model.date.format('M-DD-YYYY'))
    @twStartDate = new Pikaday
      field: @$el.find('.twPromoDate')[0]
      format: 'M-DD-YYYY'
      minDate: moment().toDate()

  initTimePickers: =>
    @$el.find('.timepicker').timepicker
      scrollDefaultTime : "12:00"
      step : 15
    if not @model.isNew()
      @$el.find('.startTime').timepicker('setTime', @model.getStartDate().toDate());
      @$el.find('.endTime').timepicker('setTime', @model.getEndDate().toDate());

  saveFacebook:(e) ->
    Chaplin.mediator.publish 'startWaiting'
    e.preventDefault()
    message = $('.message').val()
    successMessageAppend ="" 
    link =  $('.link-input').val()
    immediate = $('.immediate-box')
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
        caption:@event.get('name')
        title: @event.get('name')
        pageId: page
        pageAccessToken:@pageAccessToken
        promotionTime: moment().toDate().toISOString()
        media: @event.get('media[0]')?._id
        promotionTarget: @fbPromoTarget._id
        pushType: 'FACEBOOK-POST'
      pr.eventId = @event.id
      pr.save {}, {
        success:(item)=>
          Chaplin.mediator.publish 'stopWaiting'
          @publishEvent 'notify:publish', 'Your Facebook event promotion will magically appear shortly.'

        error:(error)=>
          Chaplin.mediator.publish 'stopWaiting'
      }    
    else if time? > 0 
      d= moment(date).toDate().toISOString()
      if now >= moment(d).format('X')
        successMessageAppend = "You chose a date in the past, your message will go out immediately."
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
        error:(error)=>
          Chaplin.mediator.publish 'stopWaiting'
      }
    else 
      Chaplin.mediator.publish 'stopWaiting'
      @publishEvent 'notify:publish', {type:'error', message: "When do you want the magic to happen? Please tell us below."}
        
  
  saveTwitter: (e)->
    e.preventDefault()
    successMessageAppend ="" 
    message = $('.tweetMessage').val()
    immediate = $('.tw-immediate-box')
    date = @twStartDate.getMoment()
    time = $('.twStartTime').timepicker('getSecondsFromMidnight')
    now = moment().format('X')
    date = date.add('seconds', time)
    if immediate.is(':checked')
      pr = new PromotionRequest
        message: message
        promotionTime: moment().toDate().toISOString()
        media: @event.get('media')[0]?._id
        promotionTarget: @twPromoTarget._id
        pushType: 'TWITTER-POST'
      pr.eventId = @event.id
      pr.save {},{
        success:(response, doc)=>
            Chaplin.mediator.publish 'stopWaiting'
            @publishEvent 'notify:publish', "Your Twitter event promotion will go out as soon as possible."
        error:(error)=>
          Chaplin.mediator.publish 'stopWaiting'
      }
    else if time? > 0 
      if date and now >= moment(date).format('X')
        successMessageAppend = "You chose a date in the past so your message will go out immediately."
      scheduled= new PromotionRequest
        message: message
        promotionTime: moment(date).toDate().toISOString()
        media: @event.get('media')[0]?._id
        promotionTarget: @twPromoTarget._id
        pushType: 'TWITTER-POST'
      scheduled.eventId = @event.id
      scheduled.save {},{
        success:(response, doc) =>
          Chaplin.mediator.publish 'stopWaiting'
          @publishEvent 'notify:publish', "Your Twitter event promotion has been scheduled for #{moment(date).format("ddd, MMM D YYYY  h:mm A")}. #{successMessageAppend}"
        error:(response,err)=>
          Chaplin.mediator.publish 'stopWaiting'
      }
    else 
      Chaplin.mediator.publish 'stopWaiting'
      @publishEvent 'notify:publish', {type:'error', message: "When do you want the magic to happen? Please tell us below."}
        
  showFacebook: (e)=>
    if e
      e.preventDefault()
    $('.twitterTab').removeClass('active')
    $('.facebookTab').addClass('active')
    $('.facebookEventTab').removeClass('active')
    $('#facebookPanel').show()
    $('#twitterPanel').hide()
    $('#facebookEventPanel').hide() 

  showFacebookEvent: (e)=>
    if e
      e.preventDefault()
    $('.twitterTab').removeClass('active')
    $('.facebookTab').removeClass('active')
    $('.facebookEventTab').addClass('active')
    options=
      business:@business
      promotionTarget:@fbPromoTarget
    @subview("facebookEvent", new CreateFacebookEventView({model: @event, container : @$el.find('.facebook-event-preview')[0], options:options}))
    @subview('event-address', new AddressView({container : @$el.find('.event-map'), model : @model}))  
    $('input.address').remove()
    $('label[for=address]').remove()
    $('#facebookEventPanel').show()
    $('#facebookPanel').hide()
    $('#twitterPanel').hide()

  showTwitter: (e)=>
    if e
      e.preventDefault()
    $('.facebookTab').removeClass('active')
    $('.twitterTab').addClass('active')
    $('.facebookEventTab').removeClass('active')
    $('#twitterPanel').show()
    $('#facebookPanel').hide() 
    $('#facebookEventPanel').hide() 

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
    pr = new PromotionRequest
      pushType: "FACEBOOK-EVENT"
      link:@event.get('website')
      caption:@event.get('name')
      title: @event.get('name')
      startTime: moment(@event.nextOccurrence()).toDate().toISOString()
      promotionTime: date
      location: @event.get('location').address
      pageId:page
      ticket_uri: @event.get('ticketUrl')
      pageAccessToken: @pageAccessToken
      promotionTarget: @fbPromoTarget._id
      media: @event.get('media')[0]?._id
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
    element = $('.immediate-box')
    if element.is(':checked')
      @hideFbDates()
    else
      @showFbDates()

  twitterImmediateClick:()->
    element = $('.tw-immediate-box')
    if element.is(':checked')
      @hideTwitterDates()
    else
      @showTwitterDates()
  hideFbDates:()->
    @$el.find('.postStartTime').hide()
    @$el.find('.postDate').hide()

  showFbDates:()->
    @$el.find('.postStartTime').show()
    @$el.find('.postDate').show()

  showTwitterDates:()->
    @$el.find('.twPostTime').show()
    @$el.find('.twPostDate').show()

  hideTwitterDates:()->
    @$el.find('.twPostTime').hide()
    @$el.find('.twPostDate').hide()

  showCreatedMessage: (data) =>
    $("html, body").animate({ scrollTop: 0 }, "slow");
    if _.isObject data
      if data.type
        @publishEvent 'message:publish', "#{data.type}", "#{data.message}"
      else
        @publishEvent 'message:publish', 'success', "Your #{@noun} has been created. <a href='##{data.id}'>View</a>"
    else if _.isString(data)
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
