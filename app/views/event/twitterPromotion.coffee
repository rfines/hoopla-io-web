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
  dashboard = false

  initialize:(options) ->
    super(options)  
    @event = options.data
    @dashboard = options.edit if options.edit
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
    td.showFormControls = @dashboard
    td.previewText = "Make sure to check out this cool event! #{@event.get('name')} hosted by #{Chaplin.datastore.business.get(@event.get('host'))?.get('name')}."
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
    "click .twitterPostBtn" : "saveTwitter"
    "click .cancelBtn":"cancel"
    "click .twitterTab" : "showTwitter"
    "change .tw-immediate-box":"twitterImmediateClick"
    "change .tw-scheduled-box":"scheduledClick"
    "keyup .tweetMessage":"updateTwitterPreivewText"
    "change .tw-image-box":"deductImageFromTotal"
    "click .showTweetFormBtn":"showTweetForm"
    "change .tw-cusLink-box": "showLinkBox"
    'change .tw-lrLink-box':"hideLinkBox"
  
    
  sendTweet:(data)=>
    @event = data.event
    @saveTwitter(null,data.callback)


  initDatePickers: =>
    @twStartDate = new Pikaday
      field: @$el.find('.twPromoDate')[0]
      minDate: moment().toDate()
      format: 'M-DD-YYYY'
      defaultDate :  @event.getEndDate().toDate()
      setDefaultDate : true
    if not @model.isNew()
      @twStartDate.setMoment @event.date
      @twStartDate.setDate(@event.getStartDate().toDate())

  initTimePickers: =>
    @$el.find('.twStartTime').timepicker
      scrollDefaultTime : moment().format('hh:mm a')
      step : 15
    @$el.find('.twStartTime').timepicker('setTime',moment().toDate())


  saveTwitter: (e,cb)->
    e.preventDefault() if e
    if not cb
      Chaplin.mediator.publish 'startWaiting'
    successMessageAppend ="" 
    message = @$el.find('.tweetMessage').val()
    immediate = @$el.find('.tw-immediate-box')
    date = @twStartDate.getMoment()
    time = moment(@$el.find('.twStartTime').timepicker('getTime')).format('hh:mm a')
    now = moment().format('X')
    date = moment("#{date.format("MM-DD-YYYY")} #{time}")
    console.log date
    med = undefined
    link=""
    if @$el.find('#linkLr').is(':checked')
      link = "http://www.localruckus.com/event/#{@event.id}"
    else if @$el.find('#linkCustom').is(':checked')
      link = @$el.find('.customLinkBox').val() 
    if @$el.find('.tw-image-box').is(':checked')
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
          resp = {}
          resp.twPublished = true
          if cb
            cb null, resp
          else
            console.log response
            @publishEvent "twitter:tweetCreated", pr
        error:(error)=>
          Chaplin.mediator.publish 'stopWaiting'
          response = {}
          response.twPublished = false
          response.error = error
          if cb
            cb error, response
          else
            @publishEvent "twitter:tweetFailed", error
      }
    else if time? > 0 
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
          resp = {}
          resp.twFinished = true
          if cb
            cb null, resp
          else
            @publishEvent "twitter:tweetCreated", scheduled
        error:(err)=>
          Chaplin.mediator.publish 'stopWaiting'
          response = {}
          response.twFinished = false
          response.error = err
          if cb
            cb null, response
          else
            console.log response
            console.log doc
            @publishEvent "twitter:tweetFailed", err
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
  stripHtml:(text)=>
    regex = /(<([^>]+)>)/ig
    text.replace(regex, "")
    text