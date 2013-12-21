template = require 'templates/event/create'
View = require 'views/base/inlineEdit'
Event = require 'models/event'
AddressView = require 'views/address'
MediaMixin = require 'views/mixins/mediaMixin'

module.exports = class EventCreateView extends View
  className: 'event-create'
  template: template
  listRoute: 'myEvents'
  noun : 'event'
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
    if not @model.isNew()
      @startDate.setMoment @model.getStartDate()
      $('.startDate').val(@model.getStartDate().format('M-DD-YYYY'))
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
      scrollDefaultTime : "12:00"
      step : 15
    if not @model.isNew()
      @$el.find('.startTime').timepicker('setTime', @model.getStartDate().add('minutes', @model.get('tzOffset')).toDate()) if @model.getStartDate()
      @$el.find('.endTime').timepicker('setTime', @model.getEndDate().add('minutes', @model.get('tzOffset')).toDate()) if @model.getEndDate()
    @$el.find('.startTime').on 'changeTime', @predictEndTime


  predictEndTime: =>
    if not @$el.find('.endTime').val()
      st = @$el.find('.startTime').timepicker('getSecondsFromMidnight')
      @$el.find('.endTime').timepicker('setTime', st+(60*60)) 
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
    if $('.promote-checkbox').is(':checked')
      if @isNew
        tracking = {"email" : Chaplin.datastore.user.get('email')}
        tracking["#{@noun}-name"] = @model.get('name')
        @publishEvent 'trackEvent', "create-#{@noun}", tracking      
        @collection.add @model
        @publishEvent '#{@noun}:created', @model
      Chaplin.helpers.redirectTo {url: "/event/#{@model.id}/promote"}
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
    @closeAll(e)
    $('.stepTwoPanel').show()
  showStepThree:(e)=>
    e.preventDefault() if e
    @closeAll(e)
    $('.stepThreePanel').show()
  showStepOne:(e)=>
    e.preventDefault() if e
    @closeAll(e)
    $('.stepOnePanel').show()
  closeAll:(e)=>
    e.preventDefault() if e
    $('.stepOnePanel, .stepTwoPanel, .stepThreePanel').hide()