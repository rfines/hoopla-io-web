View = require 'views/base/view'
PromotionRequest = require 'models/promotionRequest'

module.exports = class CreatePromotionReqeust extends View
  template: require 'templates/event/createPromotionRequest'
  autoRender: true
  className: 'create-promotion-requests'
  event: {}
  business: {}
  facebookImgUrl= undefined
  twitterImgUrl=undefined
  facebookProfileName = undefined
  twitterHandle = undefined
  fbPromoTarget = {}
  twPromoTarget = {}

  initialize:(options) ->
    super(options)
    @event = options.data
    @business = Chaplin.datastore.business.get(@event.attributes.business)
    @fbPromoTarget = _.find(@business.attributes.promotionTargets, (item) =>
      return item.accountType is 'FACEBOOK'
      )
    @facebookImgUrl = @fbPromoTarget?.profileImageUrl
    @facebookProfileName = @fbPromoTarget?.profileName
    @twPromoTarget =_.find(@business.attributes.promotionTargets, (item) =>
      return item.accountType is 'TWITTER'
      )
    @twitterImgUrl = @twPromoTarget?.profileImageUrl
    @twitterHandle =  @twPromoTarget?.profileName 

  getTemplateData: ->
    td = super()
    td.facebookProfileImageUrl = @facebookImgUrl
    td.twitterProfileImageUrl = @twitterImgUrl
    td.facebookProfileName = @facebookProfileName
    td.twitterHandle = @twitterHandle
    td.previewText = "Event Name: #{@event.attributes.name}  Date: #{@event.nextOccurrence().format('MMM DD, YYYY')} Time: #{moment(@event.nextOccurrence()).format("h:mm A")}"
    if not @fbPromoTarget
      td.showFb = false
    else
      td.showFb =true
    if not @twPromoTarget
      td.showTwitter = false
    else
      td.showTwitter = true
    td
  
  attach : ->
    super
    if @fbPromoTarget
      @showFacebook()
    else
      @showTwitter()
    @initDatePickers()
    @initTimePickers()

  events: 
    "submit form.promoRequestFormFacebook": "saveFacebook"
    "submit form.promoRequestFormTwitter" : "saveTwitter"
    "click .facebookTab" : "showFacebook"
    "click .twitterTab" : "showTwitter"

  initDatePickers: =>
    @startDate = new Pikaday
      field: @$el.find('.promoDate')[0]
    if not @model.isNew()
      startDate.setMoment @model.date
      $('.promoDate').val(@model.date.format('YYYY-MM-DD'))
    @twStartDate = new Pikaday
      field: @$el.find('.twPromoDate')[0]

  initTimePickers: =>
    @$el.find('.timepicker').timepicker
      scrollDefaultTime : "12:00"
      step : 15
    if not @model.isNew()
      @$el.find('.startTime').timepicker('setTime', @model.getStartDate().toDate());
      @$el.find('.endTime').timepicker('setTime', @model.getEndDate().toDate());

  saveFacebook:(e) ->
    console.log @fbPromoTarget
    e.preventDefault()
    message = $('.message').val()
    immediate = $('.immediate-box').val()
    date = @startDate.getMoment()
    time = $('.startTime').timepicker('getSecondsFromMidnight')
    date = date.add('seconds', time)
    if immediate is 'fbImmediate'
      pr = new PromotionRequest
        message: message
        startTime: moment().toDate().toISOString()
        media: @event.attributes.media[0]?._id
        promotionTarget: @fbPromoTarget._id
        pushType: 'FACEBOOK-POST'
      pr.eventId = @event.id
      pr.save (err, doc)=>
        if err
          console.log err
        else if date?.length <=0
          @publishEvent '!router:route', '/myEvents'

    if time? > 0 
      scheduled= new PromotionRequest
        message: message
        startTime: moment(date).toDate().toISOString()
        media: @event.attributes.media[0]?._id
        promotionTarget: @fbPromoTarget._id
        pushType: 'FACEBOOK-POST'
      scheduled.eventId = @event.id
      scheduled.save (error, doc) =>
        if error
          console.log error
        else
          console.log "Redirect?"
          @publishEvent '!router:route', '/myEvents'

  saveTwitter: (e)->
    console.log @twPromoTarget
    e.preventDefault()
    message = $('.tweetMessage').val()
    immediate = $('.tw-immediate-box').val()
    date = @twStartDate.getMoment()
    time = $('.twStartTime').timepicker('getSecondsFromMidnight')
    date = date.add('seconds', time)
    if immediate is 'twImmediate'
      pr = new PromotionRequest
        message: message
        startTime: moment().toDate().toISOString()
        media: @event.attributes.media[0]?._id
        promotionTarget: @twPromoTarget._id
        pushType: 'TWITTER-POST'
      pr.eventId = @event.id
      pr.save (err, doc)=>
        if err
          console.log err
        else if date?.length <=0
          @publishEvent '!router:route', '/myEvents'

    if time? > 0 
      scheduled= new PromotionRequest
        message: message
        startTime: moment(date).toDate().toISOString()
        media: @event.attributes.media[0]?._id
        promotionTarget: @twPromoTarget._id
        pushType: 'TWITTER-POST'
      scheduled.eventId = @event.id
      scheduled.save (error, doc) =>
        if error
          console.log error
        else
          @publishEvent '!router:route', '/myEvents'
  showFacebook: (e)=>
    if e
      e.preventDefault()
    $('.twitterTab').removeClass('active')
    $('.facebookTab').addClass('active')
    $('#facebookPanel').show()
    $('#twitterPanel').hide()

  showTwitter: (e)=>
    if e
      e.preventDefault()
    $('.facebookTab').removeClass('active')
    $('.twitterTab').addClass('active')
    $('#twitterPanel').show()
    $('#facebookPanel').hide() 