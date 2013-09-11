View = require 'views/base/view'
PromotionRequest = require 'models/promotionRequest'
FacebookPagesView = require 'views/event/facebookPages'
CreateFacebookEventView = require 'views/event/createFacebookEvent'
AddressView = require 'views/address'

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
  fbPages = []

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
    @getFacebookPages(@fbPromoTarget)
    
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
    options=
      business:@business
      promotionTarget:@fbPromoTarget
    @subview("facebookEvent", new CreateFacebookEventView({model: @event, container : @$el.find('.facebook-event-preview')[0], options:options}))
    @initDatePickers()
    @initTimePickers()
    @subview('event-address', new AddressView({container : @$el.find('.event-map'), model : @model}))  
    $('input.address').remove()
    $('label[for=address]').remove()
    

  events: 
    "click .facebookPostBtn": "saveFacebook"
    "submit form.promoRequestFormTwitter" : "saveTwitter"
    "click .createFbEventBtn":"saveFbEvent"
    "click .cancelBtn":"cancel"
    "click .facebookTab" : "showFacebook"
    "click .twitterTab" : "showTwitter"
    "click .facebookEventTab":"showFacebookEvent"
    
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
    e.preventDefault()
    message = $('.message').val()
    immediate = $('.immediate-box')
    date = @startDate.getMoment()
    time = $('.startTime').timepicker('getSecondsFromMidnight')
    date = date.add('seconds', time)
    page = $('.pages>.facebook-pages>.pageSelection').val()
    @pageAccessToken = _.find(@fbPages, (item)=>
      return item.id is page).access_token
    if immediate.is(':checked')
      pr = new PromotionRequest
        message: message
        pageId: page
        pageAccessToken:@pageAccessToken
        promotionTime: moment().toDate().toISOString()
        media: @event.attributes.media[0]?._id
        promotionTarget: @fbPromoTarget._id
        pushType: 'FACEBOOK-POST'
      
      @postToFacebookNow(@fbPromoTarget,pr,@event.attributes.media[0]?.url,(err,promotionRequest)=>
        if err
          console.log err
          promotionRequest.status=
            code: 'WAITING'
            retryCount:1
          promotionRequest.eventId = @event.id
          promotionRequest.save (error, doc)=>
            if error
              console.log error
            else if time? <=0
              @publishEvent '!router:route', '/myEvents'    
        else
          promotionRequest.status=
            code: 'COMPLETE'
            retryCount:0
            completedDate: moment().toDate().toISOString()
          promotionRequest.eventId = @event.id
          promotionRequest.save (error, doc)=>
            if error
              console.log error
            else if time? <=0
              @publishEvent '!router:route', '/myEvents'    
      )
    if time? > 0 
      d= moment(date).toDate().toISOString()
      scheduled= new PromotionRequest
        message: message
        media: @event.attributes.media[0]?._id
        promotionTarget: @fbPromoTarget._id
        pushType: 'FACEBOOK-POST'
        pageId:page
        pageAccessToken: @pageAccessToken
        promotionTime: d

      @postScheduledFacebook(@fbPromoTarget,scheduled,@event.get('media')[0]?.url,d,(err,promoReq)=>
        if err
          console.log err
          promoReq.status=
            code: 'WAITING'
            lastError:err
            retryCount:1
          promoReq.save (error, doc)=>
            if error
              console.log error
            else if time? <=0
              @publishEvent '!router:route', '/myEvents'  
        else
          promoReq.status=
            code: 'COMPLETE'
            retryCount:0
            completedDate: moment().toDate().toISOString()
          promoReq.eventId = @event.id
          promoReq.save (error, doc)=>
            if error
              console.log error
            else
              console.log "Redirect?"
              @publishEvent '!router:route', '/myEvents' 
      )   

  postToFacebookNow: (pt,pr, imageUrl, cb)=>
    console.log "Posting to facebook now"
    console.log pt
    if pt.accessToken && pr.attributes.pageId
      post=
        message: pr.attributes.message
        caption: "#{@event.get('name')} #{@event.get('location').address} #{pr.attributes.message}"
        picture: @event.attributes.media[0]?.url
        title: @event.get('name')
      $.ajax
        url:"https://graph.facebook.com/#{pr.attributes.pageId}/feed?access_token=#{pt.accessToken}"
        method:'POST'
        data:post
        success:(response, body)=>
          cb null, pr
        failure:(err)=>
          console.log err
          pr.status=
            code:'WAITING'
            retryCount:0
            lastError: err
          cb err, pr
  postScheduledFacebook: (pt,pr,imageUrl,date,cb)=>
     if pr.attributes.pageAccessToken && pr.attributes.pageId
      post=
        message: pr.attributes.message
        caption: "#{@event.get('name')} #{@event.get('location').address}"
        picture: @event.attributes.media[0]?.url
        title: @event.get('name')
        published:false
        scheduled_publish_time:moment(date).format('X')
      console.log post
      $.ajax
        url:"https://graph.facebook.com/#{pr.attributes.pageId}/feed?access_token=#{pr.attributes.pageAccessToken}"
        method:'POST'
        data:post
        success:(response, body)=>
          cb null, pr
        failure:(err)=>
          console.log err
          pr.status=
            code:'WAITING'
            retryCount:0
            lastError: err
          cb err, pr
  saveTwitter: (e)->
    e.preventDefault()
    message = $('.tweetMessage').val()
    immediate = $('.tw-immediate-box').val()
    date = @twStartDate.getMoment()
    time = $('.twStartTime').timepicker('getSecondsFromMidnight')
    date = date.add('seconds', time)
    if immediate is 'twImmediate'
      pr = new PromotionRequest
        message: message
        promotionTime: moment().toDate().toISOString()
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
        promotionTime: moment(date).toDate().toISOString()
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
          @subview("facebookEventPages", new FacebookPagesView({model: @model, container : @$el.find('.event-pages')[0], options:options}))
        failure:(err)=>
          console.log err
          return null

  addCharacter:(e)=>
    code = String.fromCharCode(((if e.keyCode then e.keyCode else e.which)))
    currentPreviewMessage = $('.preview-message').html()
    currentPreviewMessage= currentPreviewMessage + code
    $('.preview-message').html(currentPreviewMessage)

  saveFbEvent:(e)=>
    e.preventDefault()
    page=$('.event-pages>.facebook-pages>.pageSelection').val()
    @pageAccessToken = _.find(@fbPages, (item)=>
      return item.id is page
      )?.access_token
    at = @fbPromoTarget.accessToken
    if @pageAccessToken
      at = @pageAccessToken
    date = moment().toDate().toISOString()
    data =
      name: @event.get('name')
      description:@event.get('description')
      picture:@event.get('media')[0]?.url
      location:@event.get('location').address
      start_time:moment(@event.nextOccurrence()).toDate().toISOString()

    pr = new PromotionRequest
      pushType: "FACEBOOK-EVENT"
      title: @event.name
      startTime: moment(@event.nextOccurrence()).toDate().toISOString()
      promotionTime: date
      location: @event.get('location').address
      pageId:page
      pageAccessToken: @pageAccessToken
      promotionTarget: @fbPromoTarget.id
      media: @event.get('media')[0]?._id
    $.ajax
      url:"https://graph.facebook.com/#{page}/events?access_token=#{at}"
      method:'POST'
      contentType: "application/json"
      data:data
      success:(response, body)=>
        pr.status=
            code: 'COMPLETE'
            retryCount:0
            completedDate: moment().toDate().toISOString()
        pr.eventId = @event.id
        pr.save (err,doc)=>
          @publishEvent '!router:route', '/myEvents'
      failure:(err)=>
        console.log err
        pr.status=
          code: 'WAITING'
          retryCount:1
          lastError:
            message=err?.message

        pr.eventId = @event.id
        pr.save (err,doc)=>
          console.log "Saved"
          if err
            console.log err
          else
            console.log "Posted event to facebook"
            console.log doc
            @publishEvent '!router:route', '/myEvents'    

  cancel:(e)->
    e.preventDefault()
    @publishEvent '!router:route', '/myEvents'

 