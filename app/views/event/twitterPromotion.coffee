View = require 'views/base/view'
PromotionRequest = require 'models/promotionRequest'
MessageArea = require 'views/messageArea'

module.exports = class CreatePromotionReqeust extends View
  template: require 'templates/event/createTwitterPromotionRequest'
  className: 'create-twitter-promotion-requests'
  event: {}
  business: {}
  noun: 'promotion'
  twitterImgUrl=undefined
  twitterHandle = undefined
  twPromoTarget = undefined

  initialize:(options) ->
    super(options)  
    @event = options.data
    @business = Chaplin.datastore.business.get(@event.get('business')) 
    @twPromoTarget =_.find(@business.attributes.promotionTargets, (item) =>
      return item.accountType is 'TWITTER'
      )
    @subscribeEvent "notify:publish", @showCreatedMessage if @showCreatedMessage
    @subscribeEvent "event:promoteTwitter", @sendTweet
    @twitterImgUrl = @twPromoTarget?.profileImageUrl
    @twitterHandle =  @twPromoTarget?.profileName 

    if not @model
      @model = new PromotionRequest()
    
    
  getTemplateData: ->
    td = super()
    td.previewText = "Make sure to check out this cool event! #{@event.get('name')} hosted by #{Chaplin.datastore.business.get(@event.get('host'))?.get('name')} at #{@event.get('location').address}."
    td.localruckus = "http://www.localruckus.com/event/#{@event.id}"
    td.twitterProfileImageUrl = @twitterImgUrl
    td.twitterHandle = @twitterHandle
    if @twPromoTarget
      td.showTwitter = true
    else
      td.showTwitter = false
    td
  
  attach : ->
    super
    @subview('messageArea', new MessageArea({container: '.alert-container'}))
    @$el.find('.tweetMessage').simplyCountable({
      maxCount: 140
      strictMax:true
      overClass:'alert alert-error'
      countDirection: 'down'

    })
    @initDatePickers()
    @initTimePickers()  
    

  events: 
    "submit form.promoRequestFormTwitter" : "saveTwitter"
    "click .cancelBtn":"cancel"
    "click .twitterTab" : "showTwitter"
    "change .fb-immediate-box":"twitterImmediateClick"
    "change .fb-scheduled-box":"scheduledClick"
    "keyup .tweetMessage":"updateTwitterPreivewText"
    "change .tw-image-box":"deductImageFromTotal"
    "click .showTweetFormBtn":"showTweetForm"
    "change .tw-cusLink-box": "showLinkBox"
    'change .tw-lrLink-box':"hideLinkBox"
  
    
  sendTweet:(data)=>
    @event = data.event
    $('.promoRequestFormTwitter').submit()


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
      scrollDefaultTime : moment().format('hh:mm a')
      step : 15
    if not @model.isNew()
      @$el.find('.startTime').timepicker('setTime', @model.getStartDate().toDate());
      @$el.find('.endTime').timepicker('setTime', @model.getEndDate().toDate());

  saveTwitter: (e)->
    e.preventDefault()
    successMessageAppend ="" 
    message = $('.tweetMessage').val()
    immediate = $('.tw-immediate-box')
    date = @twStartDate.getMoment()
    time = $('.twStartTime').timepicker('getSecondsFromMidnight')
    now = moment().format('X')
    date = date.add('seconds', time)
    med = undefined
    link=""
    if $('#linkLr').is(':checked')
      link = "http://www.localruckus.com/event/#{@event.id}"
    else if $('#linkCustom').is(':checked')
      link = $('.customLinkBox').val() 
    if $('.tw-image-box').is(':checked')
      med = @event.get('media')?[0]?._id
    if immediate.is(':checked')
      pr = new PromotionRequest
        message: message
        promotionTime: moment().toDate().toISOString()
        media: med
        link:link
        promotionTarget: @twPromoTarget._id
        pushType: 'TWITTER-POST'
      pr.eventId = @event.id
      pr.save {},{
        success:(response, doc)=>
          Chaplin.mediator.publish 'stopWaiting'
          @publishEvent 'notify:publish', "Your Twitter event promotion will go out as soon as possible."
          resp = {}
          resp.twPublished = true
          @publishEvent 'notify:twPublished', resp
        error:(error)=>
          Chaplin.mediator.publish 'stopWaiting'
          response = {}
          response.twPublished = false
          response.error = error
          @publishEvent 'notify:fbPublished', response
      }
    else if time? > 0 
      if date and now >= moment(date).format('X')
        successMessageAppend = "You chose a date in the past so your message will go out immediately."
      scheduled= new PromotionRequest
        message: message
        promotionTime: moment(date).toDate().toISOString()
        media: med
        link:link
        promotionTarget: @twPromoTarget._id
        pushType: 'TWITTER-POST'
      scheduled.eventId = @event.id
      scheduled.save {},{
        success:(response, doc) =>
          Chaplin.mediator.publish 'stopWaiting'
          @publishEvent 'notify:publish', "Your Twitter event promotion has been scheduled for #{moment(date).format("ddd, MMM D YYYY  h:mm A")}. #{successMessageAppend}"
          resp = {}
          resp.twFinished = true
          @publishEvent 'notify:twPublished', resp
        error:(err)=>
          Chaplin.mediator.publish 'stopWaiting'
          response = {}
          response.twFinished = false
          response.error = err
          @publishEvent 'notify:twPublished', response
      }
    else 
      Chaplin.mediator.publish 'stopWaiting'
      @publishEvent 'notify:publish', {type:'error', message: "When do you want the magic to happen? Please tell us below."}
 

  showTwitter: (e)=>
    if e
      e.preventDefault()
    @publishEvent 'message:close' 
    $('.twitterTab').addClass('active')
    $('#twitterPanel').show()
    

  addCharacter:(e)=>
    code = String.fromCharCode(((if e.keyCode then e.keyCode else e.which)))
    currentPreviewMessage = $('.preview-message').html()
    currentPreviewMessage= currentPreviewMessage + code
    $('.preview-message').html(currentPreviewMessage)

  
  cancel:(e)->
    e.preventDefault()
    Chaplin.helpers.redirectTo {url: '/myEvents'}

  twitterImmediateClick:()->
    element = $('.tw-immediate-box')
    if element.is(':checked')
      @hideDates()
    else
      @showDates()
    
  scheduledClick:(e)=>
    e.preventDefault() if e
    element = $('.tw-scheduled-box')
    if element.is(':checked')
      @showDates()
    else
      @hideDates()
      
  hideDates:()->
    @$el.find('.inputTimes').hide()

  showDates:()->
    @$el.find('.inputTimes').show()

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
  updateTwitterPreivewText:(e)=>
    keyed = @$el.find('.tweetMessage').val()
    $(".preview-message.tw").html(keyed)

  deductImageFromTotal:(e)->
    e.preventDefault() if e
    totalCount = parseInt($('.counter').html())
    if $('.tw-image-box').is(':checked')
      totalCount = totalCount-23
      if totalCount <=0
        $('.tweetMessage').addClass('alert alert-error')
      else
        $('.tweetMessage').removeClass('alert alert-error')
        $('.counter').html(totalCount)
    else
      totalCount = totalCount+23
      if totalCount <=0
        $('.tweetMessage').addClass('alert alert-error')
        $('.counter').addClass('alert alert-error')
      else
        $('.tweetMessage').removeClass('alert alert-error')
        $('.counter').removeClass('alert alert-error')
        $('.counter').html(totalCount)
  textCutter : (i, text) ->
    short = text.substr(0, i)
    return short.replace(/\s+\S*$/, "")  if /^\S/.test(text.substr(i))
    short
  showTweetForm :(e)=>
    e.preventDefault() if e
    @$el.find('.promoRequestFormTwitter').slideDown()
  showLinkBox:(e)=>
    e.preventDefault() if e
    @$el.find(".inputLink").slideDown()
  hideLinkBox:(e)=>
    e.preventDefault() if e
    @$el.find(".inputLink").slideUp()
  