template = require 'templates/event/create'
View = require 'views/base/inlineEdit'
Event = require 'models/event'
AddressView = require 'views/address'
MediaMixin = require 'views/mixins/mediaMixin'
TwitterPromo = require 'views/event/twitterPromotion'
FbPromo = require 'views/event/facebookPromotion'
FbEventPromo = require 'views/event/createFacebookEvent'

module.exports = class EventCreateView extends View
  className: 'event-create'
  template: template
  listRoute: 'myEvents'
  noun : 'event'
  model:Event
  twPromoTarget :undefined
  fbPromoTarget :undefined
  start_date : undefined
  addr_str :undefined
  fbFinsihed : undefined
  twFinished : undefined
  fbEventCreated : undefined
  ops : undefined
  hostSelected:false
  initialize: ->
    $('.stepTwoPanel').hide()
    $('.stepThreePanel').hide()
    $('.stepFourPanel').hide()
    @extend @, new MediaMixin()
    @model = new Event() if not @model
    super()
  events:
    'click .nextStepOne':'showStepTwo'
    'click .nextStepTwo':'showStepThree'
    'click .nextStepThree':'showStepFour'
    'click .stepTwoBack':'showStepOne'
    'click .stepThreeBack':'showStepTwo'
    'click .stepFourBack':'showStepThree'
    'change .twitter-checkbox':'toggleTwTab'
    'change .facebook-event-box':'toggleFbEventTab'
    'change .fb':'toggleFbTab'
    'change .tags':'updateTagPreviews'
    'keyup .website':'updateWebsitePreviews'
    'keyup .ticket':'updateTicketPreviews'
    'keyup .name':'updateNamePreviewText'
    'keyup .cost' : "updateCostPreviewText"
    'keyup .description' : "updateDescriptionPreviews"
    'keyup .phone': 'updatePhonePreviews'
    'keyup .contact':'updateContactPreviews'
    

  getTemplateData: =>
    td = super()
    td.businesses = Chaplin.datastore.business.models
    td.venues = Chaplin.datastore.venue.models
    td.eventTags = Chaplin.datastore.eventTag.models
    if @model.get('media')>0
      td.hasMedia = true
    td        

  attach: =>
    @$el.find(".select-chosen.host").chosen({width:'90%'})
    super
    @initTimePickers()
    @initDatePickers()
    @initLocation()
    @delegate 'click', '.showMediaLibrary', @showMediaLibrary
    @delegate 'click', '.addressButton', @chooseCustomVenue
    @delegate 'submit', 'form.form-create', (e)->
      e.preventDefault()    
    @$el.find('.business').on 'change', @changeBusiness
    @$el.find('.host').on 'change', @changeHost     
    @subscribeEvent 'selectedMedia', @updateImage
    @subscribeEvent 'updateImagePreviews', @updateImagePreviews
    @initSchedule()
    @editor.on('change', @storeDescription)
    @showStepOne()
    @$el.find('.change-image-btn').show()
    @$el.find(".nav-pills a[data-toggle=tab]").on "click", (e) ->
      if $(this).hasClass("disabled")
        e.preventDefault()
        false
      else
        e.preventDefault()
        $(this).tab "show"
    
    b = Chaplin.datastore.business.models[0]
    if Chaplin.datastore.business.models.length is 1
      @model.set
        business : b.id
      @$el.find('.host').trigger("chosen:updated")
    @twPromoTarget =_.find(b.get('promotionTargets'), (item) =>
      return item.accountType is 'TWITTER'
    )
    @fbPromoTarget =_.find(b.get("promotionTargets"), (item) =>
      return item.accountType is 'FACEBOOK'
    )
    if not @twPromoTarget
      @$el.find('.twitter_box').hide()
    else
      @$el.find('.twitter_box').show()
    if not @fbPromoTarget
      @$el.find('.facebook_box').hide()
      @$el.find('.facebook_event_box').hide()
    else
      @$el.find('.facebook_box').show()
      @$el.find('.facebook_event_box').show()
    @setBusinessPreview(b.get('name'), b.get('location')?.address)

  setBusinessPreview:(name, address)=>
    if name and name.length >0
      $('.venue_preview').text("#{name}")
    if not @hostSelected
      @updateAddressText("#{address}")
      @$el.find('.host').trigger("chosen:updated")

  updateImagePreviews:(image, url)=>
    iEl = @$el.find('.imagePreview')
    if iEl.length >1
      _.each iEl, (item, index, list)=>
        if not image and url?.length > 0
          item.src = url
        else
          item.src =  image.get('url')
    else
      if not image and url?.length > 0
        iEl.src = url
      else
        iEl.src= image.get('url')
  changeBusiness: (evt, params) =>
    b = Chaplin.datastore.business.get(params.selected)
    @model.set 'business', params.selected
    name = b?.get('name')
    ad = b.get('location').address
    @setBusinessPreview(name, ad.toString())
    @twPromoTarget =_.find(b?.get('promotionTargets'), (item) =>
      return item.accountType is 'TWITTER'
    )
    @fbPromoTarget =_.find(b?.get("promotionTargets"), (item) =>
      return item.accountType is 'FACEBOOK'
    )
    if not @twPromoTarget
      @$el.find('.twitter_box').hide()
    else
      @$el.find('.twitter_box').show()
    if not @fbPromoTarget
      @$el.find('.facebook_box').hide()
      @$el.find('.facebook_event_box').hide()
    else
      @$el.find('.facebook_box').show()
      @$el.find('.facebook_event_box').show()
    if not @twPromoTarget and not @fbPromoTarget
      @$el.find('.connect-help').show()
    else
      @$el.find('.connect-help').hide()
    if not @hostSelected
      @model.set 
        'host': params.selected
        'location' : b?.get('location')
    @$el.find('.host').trigger("chosen:updated")

  changeHost:  (evt, params) =>
    @hostSelected = true
    b = Chaplin.datastore.venue.get(params.selected)
    $('.venue_preview').text("#{b.get('name')}") 
    @updateAddressText("#{b?.get('location')?.address}")
    @model.set 
      'host' : params.selected
      'location' : Chaplin.datastore.venue.get(params.selected).get('location')

  storeDescription:()=>
    @description = @$el.find('.description').val()
    @updateDescriptionPreviews()

  toggleTwTab:(e)=>
    e.preventDefault() if e
    if @$el.find('.twitter-checkbox').is(':checked')
      @$el.find('.twitter_tab_a, .twitter_tab').removeClass('disabled')
      @initTwitterPromotion()
    else
      @$el.find('.twitter_tab_a, .twitter_tab').addClass('disabled')
      if @$el.find('.twitter-preview').is(':visible')
        @$el.find('.nav-pills a[href="#web"]').tab('show')
  
  initTwitterPromotion : =>
    @subview 'twitterPromo', new TwitterPromo({
      container : @$el.find('.twitter_container')
      template: require('templates/event/createTwitterPromotionRequest')
      data:@model
      })
  
  toggleFbTab:(e)=>
    e.preventDefault() if e
    if @$el.find('.fb').is(':checked')
      @$el.find('.fb_tab_a, .facebook_tab').removeClass('disabled')
      @initFacebookPromotion()
    else
      @$el.find('.fb_tab_a, .facebook_tab').addClass('disabled')
      if @$el.find('.facebook-preview').is(':visible')
        @$el.find('.nav-pills a[href="#web"]').tab('show')


  initFacebookPromotion :()=>
    @model.set
      startDate : @start_date 
    @subview 'facebookPromo', new FbPromo({
      container:@$el.find('.facebook_container')
      template: require('templates/event/createFacebookPromotionRequest')
      data:@model
    })
  toggleFbEventTab:(e)=>
    if @$el.find('.facebook-event-box').is(':checked')
      @$el.find('.fbEvent_tab_a, .facebook_event_tab').removeClass('disabled')
      @initFacebookEventPromotion()
    else
      @$el.find('.fbEvent_tab_a, .facebook_event_tab').addClass('disabled')
      if @$el.find('.event-page-preview').is(':visible')
        @$el.find('.nav-pills a[href="#web"]').tab('show')

  initFacebookEventPromotion :()=>
    @model.set
      startDate : @start_date 
    data={
      event:@model
      promotionTarget:@fbPromoTarget
      business:Chaplin.datastore.business.get(@model.get('business'))
    }
    @subview 'facebookEventPromo', new FbEventPromo({
      container:@$el.find('.facebook_event_container')
      template: require('templates/event/createFacebookEvent')
      options:data
    })
  initSchedule: =>
    if @model.get('schedules')?.length > 0
      @$el.find('.repeats').attr('checked', true)
      @$el.find('.recurringScheduleDetails').show()
      s = @model.get('schedules')[0]
      if s.dayOfWeek?.length is 0 and s.dayOfWeekCount?.length is 0
        @initDaily(s)
      else
        if s.dayOfWeekCount?.length > 0
          @initMonthly(s)
        else
          @initWeekly(s)
    else
      @$el.find('.recurringScheduleDetails').hide()
    @delegate 'change', 'input.repeats', =>
      if @$el.find('input.repeats:checked').val()
        @initDaily({}) if not @model.get('recurrenceInterval')
        @$el.find('.recurringScheduleDetails').show()
      else
        @$el.find('.recurringScheduleDetails').hide()
    @delegate 'change', 'select[name=recurrenceInterval]', =>
      @show[@$el.find('select[name=recurrenceInterval] option:selected').val()](@$el)

  show: {
    DAILY : (el) ->
      el.find('.dayOfWeekCountContainer').hide()
      el.find('.dayOfWeekContainer').hide()
    WEEKLY: (el) ->
      el.find('.dayOfWeekCountContainer').hide()
      el.find('.dayOfWeekContainer').show()
    MONTHLY: (el) ->
      el.find('.dayOfWeekCountContainer').show()
      el.find('.dayOfWeekContainer').show()  
  }

  initDaily: (schedule) =>
    @show.DAILY(@$el)
    @model.set 'recurrenceInterval', 'DAILY'

  initWeekly: (schedule) =>
    @show.WEEKLY(@$el)
    @model.set 'recurrenceInterval', 'WEEKLY'
    @model.set 'SUNDAY', true if _.contains(schedule.dayOfWeek, 1)
    @model.set 'MONDAY', true if _.contains(schedule.dayOfWeek, 2)
    @model.set 'TUESDAY', true if _.contains(schedule.dayOfWeek, 3)
    @model.set 'WEDNESDAY', true if _.contains(schedule.dayOfWeek, 4)
    @model.set 'THURSDAY', true if _.contains(schedule.dayOfWeek, 5)
    @model.set 'FRIDAY', true if _.contains(schedule.dayOfWeek, 6)
    @model.set 'SATURDAY', true if _.contains(schedule.dayOfWeek, 7) 

  initMonthly: (schedule) =>
    @show.MONTHLY(@$el)
    @model.set 'recurrenceInterval', 'MONTHLY'
    @model.set 'dayOfWeekCount', schedule.dayOfWeekCount[0]
    @model.set 'SUNDAY', true if _.contains(schedule.dayOfWeek, 1)
    @model.set 'MONDAY', true if _.contains(schedule.dayOfWeek, 2)
    @model.set 'TUESDAY', true if _.contains(schedule.dayOfWeek, 3)
    @model.set 'WEDNESDAY', true if _.contains(schedule.dayOfWeek, 4)
    @model.set 'THURSDAY', true if _.contains(schedule.dayOfWeek, 5)
    @model.set 'FRIDAY', true if _.contains(schedule.dayOfWeek, 6)
    @model.set 'SATURDAY', true if _.contains(schedule.dayOfWeek, 7) 

                
  initLocation:()=>
    if not @model.get('host') and not @isNew
      @$el.find('.custom_venue').show()
      @$el.find('.choose_venue').hide()
      @$el.find('.hostAddress').val(@model.get('location')?.address)
      @delegate 'click', '.switch_venue', ->
        @$el.find('.custom_venue').hide()
        @$el.find('.choose_venue').show()
        @$el.find('.hostAddress').val('')
      
  positionPopover:()=>
    @$el.find('.popover.bottom').css('top', '60px')  

  showMediaLibrary: (e) =>
    e.stopPropagation()
    if @model.isNew()
      @$el.find("#media-library-popover-").modal()
    else
      @$el.find("#media-library-popover-#{@model.id}").modal()

  initDatePickers: =>
    @startDate = new Pikaday
      field: @$el.find('.startDate')[0]
      format: 'M-DD-YYYY'
      minDate: moment().toDate()
      onSelect: @updateCalendarDateText
    if not @model.isNew()
      @startDate.setMoment @model.getStartDate()
      @$el.find('.startDate').val(@model.getStartDate().format('M-DD-YYYY'))
    @endDate = new Pikaday
      field: @$el.find('.endDate')[0]
      format: 'M-DD-YYYY'
      minDate: moment().toDate()      
    if @model.get('schedules')?[0]?.end
      ed = moment(@model.get('schedules')?[0]?.end)
      @endDate.setMoment ed
      @$el.find('.endDate').val(ed.format('M-DD-YYYY')) 

  initTimePickers: =>
    @$el.find('.timepicker').timepicker
      scrollDefaultTime : moment().format("hh:mm a")
      step : 15
    if not @model.isNew()
      @$el.find('.startTime').timepicker('setTime', @model.getStartDate().add('minutes', @model.get('tzOffset')).toDate()) if @model.getStartDate()
      @$el.find('.endTime').timepicker('setTime', @model.getEndDate().add('minutes', @model.get('tzOffset')).toDate()) if @model.getEndDate()

    @$el.find('.startTime').on 'changeTime', @predictEndTime
    @$el.find('.endTime').on 'changeTime', @updateTimePreviewText

  predictEndTime: =>
    st = @$el.find('.startTime').timepicker('getSecondsFromMidnight')
    s= @$el.find('.startDate').val()
    if not s
      s = moment()
    if not @$el.find('.endTime').val()
      @$el.find('.endTime').timepicker('setTime', st+(60*60))
    startTime = moment(s).startOf('day').add('seconds', st)
    startDate = startTime.calendar()
    startel = $(".start_time_preview")
    el = $('.date_preview')
    if startel.length >1
      _.each startel, (item, index, list)=>
        if startTime
          item.innerText = startTime.format('h:mm a')
        else
          item.innerText = moment().format('h:mm a')
      if startDate
        _.each el, (item, index, list)=>
          if startDate
            item.innerText = startDate
          else
            item.innerText = moment().calendar()
    else
      if startTime
        startel.innerText = startTime.format('h:mm a')
      else
        startel.innerText = moment().format('h:mm a') 
      if startDate
        el.innerText = startDate
      else
        el.innerText = moment().calendar()


  chooseCustomVenue: =>
    @$el.find('.addressButton').on 'shown.bs.popover', =>
      if @$el.find('#map-canvas').length <=0
        @$el.find('.popover-content').html("<div class='addressPopover'></div>")
        @subview 'addressPopover', new AddressView
          container : @$el.find('.addressPopover')
          model : @model
          template: require('templates/addressPopover')
    @$el.find('.addressButton').popover({placement: 'bottom',selector:".chosen-container", content : "<div class='addressPopover'>Address Finder</div>", container: 'div.address-finder', html: true}).popover('show')
    @positionPopover()
    @delegate 'click', '.closeAddress', ->
      if @$el.find('.popover-content').is(':visible')
        @$el.find('.addressButton').popover('hide')
        if @subview('addressPopover').location?.address and @subview('addressPopover').location?.address.toString()!=@model.get('location')?.address.toString()
          @$el.find('.choose_venue').hide()
          @$el.find('.custom_venue').show()
          @$el.find('.hostAddress').val(@subview('addressPopover').location?.address)
          @model.set
            location: @subview('addressPopover').location
          @updateAddressText @subview('addressPopover').location.address
        else
          @$el.find('.custom_venue').hide()
          @$el.find('.choose_venue').show()
    @delegate 'click', '.switch_venue', ->
      @$el.find('.custom_venue').hide()
      @$el.find('.choose_venue').show()
      @$el.find('.hostAddress').val('')

  getSchedules: =>
    startTime = moment().startOf('day').add('seconds', @$el.find("input[name='startTime']").timepicker('getSecondsFromMidnight'))
    endTime = moment().startOf('day').add('seconds', @$el.find("input[name='endTime']").timepicker('getSecondsFromMidnight')) 
    duration = (@$el.find("input[name='endTime']").timepicker('getSecondsFromMidnight') - @$el.find("input[name='startTime']").timepicker('getSecondsFromMidnight')) / 60  
    s = 
      start: @startDate.getMoment().toDate().toISOString()
      duration : duration
      hour : startTime.hour()
      minute: startTime.minute()
    if @endDate.getDate()
      s.end = @endDate.getMoment().toDate().toISOString()
    if @model.get('recurrenceInterval') is 'MONTHLY' or @model.get('recurrenceInterval') is 'WEEKLY'
      dayOfWeek = []
      dayOfWeek.push 1 if @model.get('SUNDAY')
      dayOfWeek.push 2 if @model.get('MONDAY')
      dayOfWeek.push 3 if @model.get('TUESDAY')
      dayOfWeek.push 4 if @model.get('WEDNESDAY')
      dayOfWeek.push 5 if @model.get('THURSDAY')
      dayOfWeek.push 6 if @model.get('FRIDAY')
      dayOfWeek.push 7 if @model.get('SATURDAY')
      s.dayOfWeek = dayOfWeek
    else
      s.dayOfWeek = []
    if @model.get('recurrenceInterval') is 'MONTHLY'
      dayOfWeekCount = [@model.get('dayOfWeekCount')] if @model.get('dayOfWeekCount')
      s.dayOfWeekCount = dayOfWeekCount || []
    else
      s.dayOfWeekCount = []
    return [s]


  getFixedOccurrences: =>
    sd = @startDate.getMoment()
    sd.add('seconds', @$el.find("input[name='startTime']").timepicker('getSecondsFromMidnight'))
    ed = @startDate.getMoment()
    ed.add('seconds', @$el.find("input[name='endTime']").timepicker('getSecondsFromMidnight'))
    return [{
      start : sd.toDate().toISOString()
      end : ed.toDate().toISOString()
    }]

  postSave:()=>
    tracking = {"email" : Chaplin.datastore.user.get('email')}
    tracking["#{@noun}-name"] = @model.get('name')
    @publishEvent 'trackEvent', "create-#{@noun}", tracking      
    @collection.add @model
    @publishEvent '#{@noun}:created', @model
    @ops = {}
    if @fbPromoTarget
      if @$el.find('.facebook-event-box').is(':checked')
        @ops.fbEvent =  @callFacebookEventPromotion
      if @$el.find('.fb').is(':checked')
        @ops.fbPost =  @callFacebookPromotion
    if @twPromoTarget
      if @$el.find('.twitter-checkbox').is(':checked')
        @ops.twPost = @callTwitterPromotion
    if !_.isEmpty @ops
      async.parallel(@ops,@finalCallback)
    else
      @publishEvent 'Event:created', {id: @model.id, message:"Well done! You have successfully created and promoted your event. You may click on the event to edit details, schedule future social media posts and analyze previous posts."} 
      Chaplin.mediator.publish 'stopWaiting'
      @publishEvent "closeOthers"
      

    
  callTwitterPromotion:(callback)=>
    data={}
    data.event = @model 
    data.twitter=true
    data.promotionTarget = @fbPromoTarget
    data.callback  = callback
    @publishEvent "event:promoteTwitter", data
  
  callFacebookPromotion:(callback)=>
    data={}
    data.event = @model 
    data.facebook = true
    data.callback  =callback
    @publishEvent "event:promoteFacebook", data
  
  callFacebookEventPromotion:(callback)=>
    data={}
    data.event = @model 
    data.callback =  callback
    @publishEvent "facebook:publishEvent", data 
  
  finalCallback:(err, results)=>
    if err
      console.log err
      @fbEventCreated = false
      @fbFinished = false
      @twFinished = false
      @publishEvent 'notify:publish', "There was a problem creating the social media promotions."
    else
      @publishEvent "closeOthers"
      @publishEvent 'Event:created', {id: @model.id, message:"Well done! You have successfully created and promoted your event. You may click on the event to edit details, schedule future social media posts and analyze previous posts."} 
      Chaplin.mediator.publish 'stopWaiting'
      

  address:()=>
    if @subview('addressPopover')?.location?.address and not @subview('addressPopover')?.location?.address!=@model.get('location')?.address
      @model.set
        location: @subview('addressPopover').location
      @model.unset('host') if @model.has('host')
  showStepTwo:(e)=>
    e.preventDefault() if e
    if @partialValidate()
      @updateProgress('step2')
      @closeAll(e)
      @updateModel()
      if @model.get('schedules')?.length >0
        @scheduleText()
      @updateStepTwoPreviews()
      $('.stepTwoPanel').show()

  showStepThree:(e)=>
    e.preventDefault() if e
    @model.set
      description: $('.description').val()
    if @partialValidate() 
      @updateProgress('step3')
      @closeAll(e)
      @updateStepThreePreviews(e)
      $('.stepThreePanel').show()
  showStepFour:(e)=>
    e.preventDefault() if e
    if @partialValidate()
      @updateProgress('step4')
      @closeAll(e)
      @toggleTwTab()
      @toggleFbTab()
      @toggleFbEventTab()
      $('.stepFourPanel').show()
  showStepOne:(e)=>
    e.preventDefault() if e
    @updateProgress('step1')
    @closeAll(e)
    $('.stepOnePanel').show()
    @updateStepOnePreviews(e)

  updateStepOnePreviews:(e)=>
    @updateNamePreviewText(e)
    @updateCalendarDateText(e)
    @updateTimePreviewText(e,undefined)
    if @model.get('location')?.address
      @updateAddressText(@model.get('location')?.address)
    if @model.get('business')
      @setBusinessPreview(Chaplin.datastore.business.get(@model.get('business')))
    if @model.get('media')?[0]
      @updateImagePreviews(undefined,@model.get('media')?[0].url)

  updateStepTwoPreviews:(e)=>
    @updateCostPreviewText(e)
    @updateDescriptionPreviews(e)
    @updateTicketPreviews(e)

  updateStepThreePreviews:(e)=>
    @updateWebsitePreviews(e)
    @updateTagPreviews(e)
    @updateContactPreviews(e)
  closeAll:(e)=>
    e.preventDefault() if e
    $('.stepOnePanel, .stepTwoPanel, .stepThreePanel, .stepFourPanel').hide()

  updateModel: =>
    if @$el.find('input.repeats:checked').val()
      @model.set
        tzOffset : moment().zone()
        schedules: @getSchedules()
        fixedOccurrences :[]
        description : @$el.find("textarea[name='description']").val().trim()
    else
      zone = moment(@getFixedOccurrences()?[0].start).zone()
      @model.set
        tzOffset : zone
        fixedOccurrences : @getFixedOccurrences()    
        schedules :[]
        description : @$el.find("textarea[name='description']").val().trim()

  updateProgress:(newValue)=>
    if newValue
      if $('.progress')
        $('.progress').removeClass('step1').removeClass('step2').removeClass('step3').removeClass('step4')
        $('.progress').addClass(newValue)
  
  updateNamePreviewText:(e)=>
    keyed = @$el.find('.name').val()
    $(".previewName").text(keyed)
    
  updateCalendarDateText:(e, text)=>
    s = @$el.find('.startDate').val()
    if not s
      s = moment()
    time = $("input[name='startTime']").timepicker('getSecondsFromMidnight')
    if not time
      startTime = moment(s)
    else
      startTime = moment(s).startOf('day').add('seconds',time)
    if startTime
      @start_date = startTime
      if text
        $(".date_preview").text(text)
      else if startTime and not text
        $('.date_preview').text(startTime.calendar())
      else
        $('.date_preview').text(moment().calendar())
      

  updateTimePreviewText:(e)=>
    s = @$el.find('.startDate').val()
    if not s
      s = moment()
    endTime = moment(s).startOf('day').add('seconds', @$el.find("input[name='endTime']").timepicker('getSecondsFromMidnight'))    
    if endTime
      $(".end_time_preview").text(endTime.format('h:mm a'))
    else
      $(".end_time_preview").text(moment().format('h:mm a'))

  updateCostPreviewText:(e)=>
    keyed = "$#{@$el.find('.cost').val()}"
    if(keyed.length >0 and keyed is not '$')
      keyed = keyed
    else
      keyed = "FREE"
    $(".cost_preview").text(keyed)
        
  updateDescriptionPreviews:(e)=>
    keyed = @$el.find('.description').val();
    $(".description_preview").html(keyed)      
    data={
      selector:".message"
      value:keyed
    }

    @publishEvent 'updateFacebookPreview', data

  updateWebsitePreviews:(e)=>
    e.preventDefault() if e
    keyed = $('.website').val()
    if keyed.length >0
      if keyed.length >= 4 and  keyed.indexOf('http') is -1
        keyed = "http://#{keyed}"
        $('.website').val(keyed)
      $(".website_preview").text(keyed)
      data = {
        selector:'.link-input'
        value: keyed

      }
      @publishEvent 'updateFacebookPreview', data

  updateTicketPreviews:(e)=>
    e.preventDefault() if e
    keyed = $('.ticket').val()
    if keyed.length >0 
      if keyed.length >=4 and  keyed.indexOf('http') is -1
        keyed = "http://#{keyed}"
        $('.ticket').val(keyed)
      if keyed != 'http://'
        $(".ticket_preview").text(keyed)
    
  updateTagPreviews:(e)=>
    e.preventDefault() if e
    tagsText = []
    keyed = @$el.find('.tags').val()
    _.each keyed, (ele, index,list)=>
      text = _.find Chaplin.datastore.eventTag.models, (item)=>
        return item.get('slug') == ele
      if text
        tagsText.push text.get('text')
    $(".tags_preview").text(tagsText.join(', '))
    

  updatePhonePreviews:(e)=>
    e.preventDefault() if e
    keyed = @$el.find('.phone').val()
    keyed = @formatPhoneNumber(keyed)
    $(".phone_preview").text(keyed)
    
  updateContactPreviews:(e)=>
    e.preventDefault() if e
    keyed = @$el.find('.contact').val()
    $(".contact_preview").text(keyed)
  

  updateAddressText:(addr)=>
    console.log addr
    $('.map_preview').text(addr)
  
  scheduleText: () =>
    out = ""
    dayOrder =  ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    dayCountOrder = ['Last', 'First', 'Second', 'Third', 'Fourth']
    s = @model.get('schedules')[0]
    s.dayOfWeek = _.sortBy s.dayOfWeek, (i) ->
      i    
    endDate = moment(s.end)
    if s.dayOfWeek?.length is 0 and s.dayOfWeekCount?.length is 0
       out = "Every Day until #{endDate.format("MM/DD/YYYY") }"
    else
      days = _.map s.dayOfWeek, (i) ->
        return dayOrder[i-1]
      if s.dayOfWeekCount?.length > 0
        out = "The #{dayCountOrder[s.dayOfWeekCount]} #{days.join(', ')} of the month"
      else
        out = "Every #{days.join(', ')}"
      if s.end
        out = "#{out} until #{endDate.format('MM/DD/YYYY')}"   
      else
        out = "#{out}"
    @updateCalendarDateText(undefined,out)

  formatPhoneNumber:(text)=>
    if text.length is 10
      return text.replace(/(\d{3})(\d{3})(\d{4})/, '($1)-$2-$3');
    else if text.length is 11
      return text.replace(/(\d)(\d{3})(\d{3})(\d{4})/, '$1-$2-$3-$4');