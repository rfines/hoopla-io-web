template = require 'templates/event/create'
View = require 'views/base/inlineEdit'
Event = require 'models/event'
AddressView = require 'views/address'
MediaMixin = require 'views/mixins/mediaMixin'
TwitterPromo = require 'views/event/twitterPromotion'
FbPromo = require 'views/event/facebookPromotion'

module.exports = class EventCreateView extends View
  className: 'event-create'
  template: template
  listRoute: 'myEvents'
  noun : 'event'
  twPromoTarget =undefined
  fbPromoTarget =undefined
  start_date = undefined
  initialize: ->
    $('.stepTwoPanel').hide()
    $('.stepThreePanel').hide()
    @extend @, new MediaMixin()
    super()
  events:
    'click .nextStepOne':'showStepTwo'
    'click .nextStepTwo':'showStepThree'
    'click .stepTwoBack':'showStepOne'
    'click .stepThreeBack':'showStepTwo'
    'keyup .name':'updateNamePreviewText'
    'keyup .cost' : "updateCostPreviewText"
    'keyup .description' : "updateDescriptionPreviews"

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
    @delegate 'submit', 'form', (e)->
      e.preventDefault()    
    @$el.find('.business').on 'change', @changeBusiness
    @$el.find('.host').on 'change', @changeHost     
    @subscribeEvent 'selectedMedia', @updateImage
    @initSchedule()

    $('.host').trigger("chosen:updated")
    $('.stepOnePanel').show()
    $("#myTab a").click (e) ->
      e.preventDefault()
      $(this).tab "show"

    $(".business.select-chosen").chosen().change (e, params) ->
      el =$('.venue_preview')
      b = Chaplin.datastore.business.get(params.selected)
      name = b?.get('name')
      @twPromoTarget =_.find(b?.get('promotionTargets'), (item) =>
        return item.accountType is 'TWITTER'
      )
      @fbPromoTarget =_.find(b?.get("promotionTargets"), (item) =>
        return item.accountType is 'FACEBOOK'
      )
      if el.length >1
        _.each el, (item, index, list)=>
            item.innerText = "#{name}"
      else
        if name.length >0
          el.innerText = "#{name}"
              
    $(".host.select-chosen").chosen().change (e, params) ->
      el =$('.venue_preview')
      b = Chaplin.datastore.business.get(params.selected)
      name = b?.get('name')
      if el.length >1
        _.each el, (item, index, list)=>
            item.innerText = "#{name}"
      else
        if name.length >0
          el.innerText = "#{name}"
  
  initTwitterPromotion : =>
    @model.attributes.description = @$el.find('.description').val()
    @subview 'twitterPromo', new TwitterPromo({
              container : @$el.find('.twitter_container')
              template: require('templates/event/createTwitterPromotionRequest')
              data:@model
              })
  initFacebookPromotion : =>
    @model.attributes.description = @$el.find('description').val()
    @model.attributes.startDate = start_date
    @subview 'facebookPromo', new FbPromo({
      container:@$el.find('.facebook_container')
      template: require('templates/event/createFacebookPromotionRequest')
      data:@model
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


  initTimePickers: =>
    @$el.find('.timepicker').timepicker
      scrollDefaultTime : "12:00"
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
    el = $('.date')
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
        if @subview('addressPopover').location?.address and not @subview('addressPopover').location?.address.toString()!=@model.get('location')?.address.toString()
          @$el.find('.choose_venue').hide()
          @$el.find('.custom_venue').show()
          @$el.find('.hostAddress').val(@subview('addressPopover').location?.address)
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
    @publishEvent 'stopWaiting'
    data={}
    data.event = @model 
    tracking = {"email" : Chaplin.datastore.user.get('email')}
    tracking["#{@noun}-name"] = @model.get('name')
    @publishEvent 'trackEvent', "create-#{@noun}", tracking      
    @collection.add @model
    @publishEvent '#{@noun}:created', @model
    if $('.promote-checkbox-twitter').is(':checked')
      data.twitter=true
      @publishEvent "event:promoteTwitter", data
    if $('.promote-checkbox-facebook').is(':checked')
      data.facebook = true
      @publishEvent "event:promoteFacebook", data
    #Chaplin.helpers.redirectTo {url: "/event/#{@model.id}/promote"}
    
    else
      super()

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
    @updateProgress('33')
    @closeAll(e)
    $('.stepTwoPanel').show()
  showStepThree:(e)=>
    e.preventDefault() if e
    @updateProgress('66')
    @closeAll(e)
    @initTwitterPromotion()
    @initFacebookPromotion()
    $('.stepThreePanel').show()
  showStepOne:(e)=>
    e.preventDefault() if e
    @updateProgress('0')
    @closeAll(e)
    $('.stepOnePanel').show()
  closeAll:(e)=>
    e.preventDefault() if e
    $('.stepOnePanel, .stepTwoPanel, .stepThreePanel').hide()
  updateProgress:(newValue)=>
    if newValue
      bar = @$el.find('.progress-bar')?[0]
      if bar
        bar.style.width = "#{newValue}%"
        sr = $('.sr-complete').innerHtml = "#{newValue} % Complete"
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
        el.innerText = keyed
      else
        el.innerText = "Event name"
  updateCalendarDateText:(e)=>
    s = @$el.find('.startDate').val()
    if not s
      s = moment()
    time = @$el.find("input[name='startTime']").timepicker('getSecondsFromMidnight')
    if not time
      time = moment()
      i = moment().startOf('day')
      secs = time.diff(i)
      time=secs
    startTime = moment(s)
    if startTime
      start_date = startTime
      el = $(".date")
      if el.length >1
        _.each el, (item, index, list)=>
          if startTime
            item.innerText = startTime.calendar()
          else
            item.innerText = moment().calendar()
      else
        if startTime
          el.innerText = startTime.calendar()
        else
          el.innerText = moment().calendar()
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
        endel.innerText =endTime.format('h:mm a')
      else
        endel.innerText = moment().format('h:mm a')
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
        el.innerText = keyed
      else
        el.innerText = "FREE"
  updateDescriptionPreviews:(e)=>
    keyed = @$el.find('.decription').val();
    el = $(".decription_preview")
    _.each el, (item, index, list)=>
      if(keyed.length >0)
        item.innerText = keyed
      else
        item.innerText = "Default message"
