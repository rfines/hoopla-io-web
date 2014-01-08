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
  twPromoTarget =undefined
  fbPromoTarget =undefined
  start_date = undefined
  addr_str = undefined
  fbFinsihed = undefined
  twFinished = undefined
  fbEventCreated = undefined
  ops = undefined
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
    'change .facebook-checkbox':'toggleFbTab'
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
    td        

  attach: =>
    @$el.find(".select-chosen.host").chosen({width:'90%'})
    super
    @initSocialMediaPromotion()
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
  
    $('.host').trigger("chosen:updated")
    $('.stepOnePanel').show()
    $(".nav-pills a[data-toggle=tab]").on "click", (e) ->
      if $(this).hasClass("disabled")
        e.preventDefault()
        false
      else
        e.preventDefault()
        $(this).tab "show"
      
    if Chaplin.datastore.business.length is 1
      @model.set
        business : Chaplin.datastore.business.models[0]
      console.log @model
      b = Chaplin.datastore.business.models[0]
      console.log b
      @twPromoTarget =_.find(b.get('promotionTargets'), (item) =>
        return item.accountType is 'TWITTER'
      )
      @fbPromoTarget =_.find(b.get("promotionTargets"), (item) =>
        return item.accountType is 'FACEBOOK'
      )
      if not @twPromoTarget
        $('.twitter_box').hide()
      else
        $('.twitter_box').show()
      if not @fbPromoTarget
        $('.facebook_box').hide()
        $('.facebook_event_box').hide()
      else
        $('.facebook_box').show()
        $('.facebook_event_box').hide()
  
  updateImagePreviews:(image)=>
    iEl = $('.imagePreview')
    if iEl.length >1
      _.each iEl, (item, index, list)=>
        item.src =  image.get('url')
    else
      iEl.src= image.get('url')
  changeBusiness: (evt, params) =>
    b = Chaplin.datastore.business.get(params.selected)
    @model.set 'business', params.selected
    el =$('.venue_preview')
    name = b?.get('name')
    @twPromoTarget =_.find(b?.get('promotionTargets'), (item) =>
      return item.accountType is 'TWITTER'
    )
    @fbPromoTarget =_.find(b?.get("promotionTargets"), (item) =>
      return item.accountType is 'FACEBOOK'
    )
    if not @twPromoTarget
      $('.twitter_box').hide()
    else
      $('.twitter_box').show()
    if not @fbPromoTarget
      $('.facebook_box').hide()
      $('.facebook_event_box').hide()
    else
      $('.facebook_box').show()
      $('.facebook_event_box').show()
    if not @twPromoTarget and not @fbPromoTarget
      $('.connect-help').show()
    else
      $('.connect-help').hide()
    if el.length >1
      _.each el, (item, index, list)=>
          item.innerText = "#{name}"
    else
      if name.length >0
        el.innerText = "#{name}"
    if not @model.has('host')
      el = $(".map_preview")
      @model.set 
        'host': params.selected
        'location' : b?.get('location')
      if el.length > 1
        _.each el, (item, index, list)=>
          item.innerText = "#{b?.get('location')?.address}"
      else
        el.innerText = "#{b?.get('location')?.address}"
      $('.host').trigger("chosen:updated")
    @showPromote(b.get('promotionTargets')?.length > 0)
  changeHost:  (evt, params) =>
    el =$('.venue_preview')
    b = Chaplin.datastore.venue.get(params.selected)
    name = b?.get('name')
    if el.length >1
      _.each el, (item, index, list)=>
          item.innerText = "#{name}"
    else
      if name.length >0
        el.innerText = "#{name}"
    el = $('.map_preview')
    if el.length > 1
      _.each el, (item, index, list)=>
        item.innerText = "#{b?.get('location')?.address}"
    else
      el.innerText = "#{b?.get('location')?.address}"
    @model.set 
      'host' : params.selected
      'location' : Chaplin.datastore.venue.get(params.selected).get('location')  
  storeDescription:()=>
    @description = $('.description').val()
    @updateDescriptionPreviews()

  toggleTwTab:(e)=>
    e.preventDefault() if e
    if $('.twitter-checkbox').is(':checked')
      $('.twitter_tab_a, .twitter_tab').removeClass('disabled')
      @initTwitterPromotion()
    else
      $('.twitter_tab_a, .twitter_tab').addClass('disabled')
      if $('.twitter-preview').is(':visible')
        $('.nav-pills a[href="#web"]').tab('show')
  
  initTwitterPromotion : =>
    @subview 'twitterPromo', new TwitterPromo({
      container : @$el.find('.twitter_container')
      template: require('templates/event/createTwitterPromotionRequest')
      data:@model
      })
  
  toggleFbTab:(e)=>
    e.preventDefault() if e
    if $('.facebook-checkbox').is(':checked')
      $('.fb_tab_a, .facebook_tab').removeClass('disabled')
      @initFacebookPromotion()
    else
      $('.fb_tab_a, .facebook_tab').addClass('disabled')
      if $('.facebook-preview').is(':visible')
        $('.nav-pills a[href="#web"]').tab('show')


  initFacebookPromotion :()=>
    @model.set
      startDate : start_date 
    @subview 'facebookPromo', new FbPromo({
      container:@$el.find('.facebook_container')
      template: require('templates/event/createFacebookPromotionRequest')
      data:@model
    })
  toggleFbEventTab:(e)=>
    if $('.facebook-event-box').is(':checked')
      $('.fbEvent_tab_a, .facebook_event_tab').removeClass('disabled')
      @initFacebookEventPromotion()
    else
      $('.fbEvent_tab_a, .facebook_event_tab').addClass('disabled')
      if $('.event-page-preview').is(':visible')
        $('.nav-pills a[href="#web"]').tab('show')

  initFacebookEventPromotion :()=>
    @model.set
      startDate : start_date 
    data={
      event:@model
      promotionTarget:@fbPromoTarget
      business:Chaplin.datastore.business.get(@model.get('business'))
    }
    @subview 'facebookEventPromo', new FbEventPromo({
      container:$('.facebook_event_container')
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
    $('.popover.bottom').css('top', '60px')  

  showMediaLibrary: (e) =>
    e.stopPropagation()
    if @model.isNew()
      $("#media-library-popover-").modal()
    else
      $("#media-library-popover-#{@model.id}").modal()

  initSocialMediaPromotion: =>
    shouldShow = @model.get('business') and Chaplin.datastore.business.get(@model.get('business')).get('promotionTargets')?.length > 0
    @showPromote(shouldShow)

  initDatePickers: =>
    @startDate = new Pikaday
      field: @$el.find('.startDate')[0]
      format: 'M-DD-YYYY'
      minDate: moment().toDate()
      onSelect: @updateCalendarDateText
    @endDate = new Pikaday
      field: @$el.find('.endDate')[0]
      format: 'M-DD-YYYY'
      minDate: moment().toDate()      
    if @model.get('schedules')?[0]?.end
      ed = moment(@model.get('schedules')?[0]?.end)
      @endDate.setMoment ed
      $('.endDate').val(ed.format('M-DD-YYYY'))      
  initTimePickers: =>
    @$el.find('.timepicker').timepicker
      scrollDefaultTime : moment().format("hh:mm a")
      step : 15
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
      if $('.facebook-event-box').is(':checked')
        @ops.fbEvent =  @callFacebookEventPromotion
      if $('.facebook-checkbox').is(':checked')
        @ops.fbPost =  @callFacebookPromotion
    if @twPromoTarget
      if $('.twitter-checkbox').is(':checked')
        @ops.twPost = @callTwitterPromotion
    if !_.isEmpty @ops
      async.parallel(@ops,@finalCallback)
    else
      @twFinished = true
      @fbEventCreated = true
      @fbFinished = true
      @removeForm 
    
  callTwitterPromotion:(callback)=>
    data={}
    data.event = @model 
    data.twitter=true
    data.promotionTarget = @fbPromoTarget
    data.callback  = callback
    @publishEvent "event:promoteTwitter", data
  promoteTwitterCallback:(result)=>
    if result.err
      console.log result.err
      @twFinished = false
      @publishEvent 'notify:publish', "There was a problem creating the twitter tweet."
    else
      @publishEvent 'notify:publish', "Well done! You have successfully created and promoted your event. You may click on the event to edit details, schedule future social media posts and analyze previous posts."
      @twFinished=true
  callFacebookPromotion:(callback)=>
    data={}
    data.event = @model 
    data.facebook = true
    data.callback  =callback
    @publishEvent "event:promoteFacebook", data
  promoteFacebookCallback:(result)=>
    if result.err
      console.log result.err
      @fbFinished = false
      @publishEvent 'notify:publish', "There was a problem creating the facebook post."
    else
      @publishEvent 'notify:publish', "Well done! You have successfully created and promoted your event. You may click on the event to edit details, schedule future social media posts and analyze previous posts."
      @fbFinished = true
  callFacebookEventPromotion:(callback)=>
    data={}
    data.event = @model 
    data.callback =  callback
    @publishEvent "facebook:publishEvent", data 
  promoteEventCallback:(result)=>
    if result.err
      console.log err
      @fbEventCreated = false
      @publishEvent 'notify:publish', "There was a problem creating the facebook event."
    else
      @publishEvent 'notify:publish', "Well done! You have successfully created and promoted your event. You may click on the event to edit details, schedule future social media posts and analyze previous posts."
      @fbEventCreated = true

  finalCallback:(err, results)=>
    if err
      console.log err
      @fbEventCreated = false
      @fbFinished = false
      @twFinished = false
      @publishEvent 'notify:publish', "There was a problem creating the social media promotions."
    else
      Chaplin.mediator.publish 'stopWaiting'
      if results.fbEvent
        @fbEventCreated = true
      else
        @fbEventCreated = undefined
      if results.fbPost
        @fbFinished = true
      else
        @fbFinished = undefined
      if results.twPost
        @twFinished = true
      else
        @twFinished = undefined
      @removeForm results

  showPromote:(show)=>
    if show
      $('.promotion-selection').show()
    else
      $('.promotion-selection').hide()
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
      console.log @model.get('schedules')
      if @model.get('schedules')?.length >0
        console.log "getting schedule text"
        @scheduleText()
      $('.stepTwoPanel').show()
  showStepThree:(e)=>
    e.preventDefault() if e
    @model.set
      description: $('.description').val()
    if @partialValidate() 
      @updateProgress('step3')
      @closeAll(e)
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
  closeAll:(e)=>
    e.preventDefault() if e
    $('.stepOnePanel, .stepTwoPanel, .stepThreePanel, .stepFourPanel').hide()

  updateModel: =>
    if @$el.find('input.repeats:checked').val()
      @model.set
        tzOffset : moment().zone()
        schedules: @getSchedules()
        fixedOccurrences :[]
        description : @$el.find("textarea[name='description']").val()
    else
      zone = moment(@getFixedOccurrences()?[0].start).zone()
      @model.set
        tzOffset : zone
        fixedOccurrences : @getFixedOccurrences()    
        schedules :[]
        description : @$el.find("textarea[name='description']").val()

  updateProgress:(newValue)=>
    if newValue
      if $('.progress')
        $('.progress').removeClass('step1').removeClass('step2').removeClass('step3').removeClass('step4')
        $('.progress').addClass(newValue)
  
  updateNamePreviewText:(e)=>
    keyed = @$el.find('.name').val()
    el = $(".previewName")
    if el.length >1
      _.each el, (item, index, list)=>
        if(keyed.length >0)
          item.innerText = keyed
        else
          item.innerText = "Event name"
    else
      if keyed.length >0
        el[0].innerText = keyed
      else
        el[0].innerText = "Event name"
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
      start_date = startTime
      el = $(".date_preview")
      if el.length >1
        _.each el, (item, index, list)=>
          if startTime and not text
            item.innerText = startTime.calendar()
          else if text
            item.innerText = text
          else
            item.innerText = moment().calendar()
      else
        if startTime and not text
          el[0].innerText = startTime.calendar()
        else if text
          el[0].innerText = text
        else
          el[0].innerText = moment().calendar()
  updateTimePreviewText:(e)=>
    s = @$el.find('.startDate').val()
    if not s
      s = moment()
    endTime = moment(s).startOf('day').add('seconds', @$el.find("input[name='endTime']").timepicker('getSecondsFromMidnight'))    
    endel = $(".end_time_preview")
    if endel.length >1
      _.each endel, (item, index, list)=>
        if endTime
          item.innerText = endTime.format('h:mm a')
        else
          item.innerText = moment().format('h:mm a')
    else
      if endTime
        endel[0].innerText =endTime.format('h:mm a')
      else
        endel[0].innerText = moment().format('h:mm a')
  updateCostPreviewText:(e)=>
    keyed = "$#{@$el.find('.cost').val()}"
    el = $(".cost_preview")
    if el.length >1
      _.each el, (item, index, list)=>
        if(keyed.length >0)
          item.innerText = keyed
        else
          item.innerText = "FREE"
    else
      if keyed.length >0
        el[0].innerText = keyed
      else
        el[0].innerText = "FREE"
  updateDescriptionPreviews:(e)=>
    keyed = @$el.find('.description').val();
    dEl = $(".description_preview")
    if dEl.length > 1
      _.each dEl, (item, index, list)=>
        item.innerText = keyed
    else
      dEl[0].innerText = keyed
    data={
      selector:".message"
      value:keyed
    }

    @publishEvent 'updateFacebookPreview', data

  updateWebsitePreviews:(e)=>
    e.preventDefault() if e
    keyed = $('.website').val()
    dEl = $(".website_preview")
    if dEl.length > 1
      _.each dEl, (item, index, list)=>
        item.innerText = keyed
    else
      dEl[0].innerText = keyed
    data = {
      selector:'.link-input'
      value: keyed

    }
    @publishEvent 'updateFacebookPreview', data

  updateTicketPreviews:(e)=>
    e.preventDefault() if e
    keyed = $('.ticket').val()
    dEl = $(".ticket_preview")
    if dEl.length > 1
      _.each dEl, (item, index, list)=>
        item.innerText = keyed
    else
      dEl[0].innerText = keyed

  updateTagPreviews:(e)=>
    e.preventDefault() if e
    tagsText = []
    keyed = @$el.find('.tags').val()
    _.each keyed, (ele, index,list)=>
      text = _.find Chaplin.datastore.eventTag.models, (item)=>
        return item.get('slug') == ele
      if text
        tagsText.push text.get('text')
    dEl = $(".tags_preview")
    if dEl.length > 1
      _.each dEl, (item, index, list)=>
        item.innerText = tagsText.join(', ')
    else
      dEl[0].innerText = tagsText.join(', ')

  updatePhonePreviews:(e)=>
    e.preventDefault() if e
    keyed = @$el.find('.phone').val()
    dEl = $(".phone_preview")
    if dEl.length > 1
      _.each dEl, (item, index, list)=>
        item.innerText = keyed
    else
      dEl[0].innerText = keyed
  updateContactPreviews:(e)=>
    e.preventDefault() if e
    keyed = @$el.find('.contact').val()
    dEl = $(".contact_preview")
    if dEl.length > 1
      _.each dEl, (item, index, list)=>
        item.innerText = keyed
    else
      dEl[0].innerText = keyed
  updateAddressText:(addr)=>
    el = $('.map_preview')
    if el.length > 1
      _.each el, (item, index, list)=>
        item.innerText = "#{addr}"
    else
      el.innerText = "#{addr}"
  removeForm:(results)=>
    if _.size(@ops) == 3
      if @twFinished and @twFinished is true and @fbFinished and @fbFinished is true and @fbEventCreated and @fbEventCreated is true
        @publishEvent "closeOthers"
        @publishEvent 'notify:publish', "Well done! You have successfully created and promoted your event. You may click on the event to edit details, schedule future social media posts and analyze previous posts."
      else
        @publishEvent 'notify:publish', "There was some unexpected problems creating your social media posts. Please try again."
    else if @ops.fbEvent and @ops.fbPost
      if @fbEventCreated is true and @fbFinished is true
        @publishEvent "closeOthers"
        @publishEvent 'notify:publish', "Well done! You have successfully created and promoted your event. You may click on the event to edit details, schedule future social media posts and analyze previous posts."
      else
        @publishEvent 'notify:publish', "There was some unexpected problems creating your social media posts. Please try again."
    else if @ops.fbEvent and @ops.twPost
      if @twFinished is true and @fbEventCreated is true
        @publishEvent "closeOthers"
        @publishEvent 'notify:publish', "Well done! You have successfully created and promoted your event. You may click on the event to edit details, schedule future social media posts and analyze previous posts."
      else
        @publishEvent 'notify:publish', "There was some unexpected problems creating your social media posts. Please try again."
    else if @ops.fbPost and @ops.twPost 
      if @fbFinished is true and @twFinished is true
        @publishEvent "closeOthers"
        @publishEvent 'notify:publish', "Well done! You have successfully created and promoted your event. You may click on the event to edit details, schedule future social media posts and analyze previous posts."
      else
        @publishEvent 'notify:publish', "There was some unexpected problems creating your social media posts. Please try again."
    else if @ops.fbPost
      if @fbFinished is true
        @publishEvent "closeOthers"
        @publishEvent 'notify:publish', "Well done! You have successfully created and promoted your event. You may click on the event to edit details, schedule future social media posts and analyze previous posts."
      else
        @publishEvent 'notify:publish', "There was some unexpected problems creating your social media posts. Please try again."
    else if @ops.twPost 
      if @twFinished is true
        @publishEvent "closeOthers"
        @publishEvent 'notify:publish', "Well done! You have successfully created and promoted your event. You may click on the event to edit details, schedule future social media posts and analyze previous posts."
      else
        @publishEvent 'notify:publish', "There was some unexpected problems creating your social media posts. Please try again."
    else if @ops.fbEvent 
      if @fbEventCreated is true
        @publishEvent "closeOthers"
        @publishEvent 'notify:publish', "Well done! You have successfully created and promoted your event. You may click on the event to edit details, schedule future social media posts and analyze previous posts."
      else
        @publishEvent 'notify:publish', "There was some unexpected problems creating your social media posts. Please try again."
           
    @publishEvent 'stopWaiting'

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