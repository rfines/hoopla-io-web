template = require 'templates/event/edit'
View = require 'views/base/inlineEdit'
Event = require 'models/event'
AddressView = require 'views/address'
MediaMixin = require 'views/mixins/mediaMixin'

module.exports = class EventEditView extends View
  autoRender: true
  className: 'event-edit'
  template: template
  listRoute: 'myEvents'
  noun : 'event'
  
  initialize: ->
    @extend @, new MediaMixin()
    super()

  getTemplateData: =>
    td = super()
    td.businesses = Chaplin.datastore.business.models
    td.venues = Chaplin.datastore.venue.models
    td.eventTags = Chaplin.datastore.eventTag.models
    td        

  attach: =>
    super
    @initSocialMediaPromotion()
    @initTimePickers()
    @initDatePickers()
    @delegate 'click', '.showMediaLibrary', @showMediaLibrary
    @delegate 'click', '.addressButton', @chooseCustomVenue
    @delegate 'submit', 'form', (e)->
      e.preventDefault()    
    @$el.find('.business').on 'change', @changeBusiness
    @$el.find('.host').on 'change', @changeHost     
    @subscribeEvent 'selectedMedia', @updateImage   

  changeHost:  (evt, params) =>
    console.log 'change host'
    @model.set 
      'host' : params.selected
      'location' : Chaplin.datastore.venue.get(params.selected).get('location')   

  changeBusiness: (evt, params) =>
    b = Chaplin.datastore.business.get(params.selected)
    @model.set 'business', params.selected
    if not @model.has('host')
      @model.set 
        'host': params.selected
        'location' : b?.get('location')
      $('.host').trigger("chosen:updated")
    @showPromote(b.get('promotionTargets')?.length > 0)

  showMediaLibrary: (e) =>
    e.stopPropagation()
    if @model.isNew()
      $("#media-library-popover-").modal()
    else
      $("#media-library-popover-#{@model.id}").modal()

  initSocialMediaPromotion: =>
    shouldShow = @model.get('business') and Chaplin.datastore.business.get(@model.get('business')).get('promotionTargets')?.length > 0
    console.log shouldShow
    @showPromote(shouldShow)

  initDatePickers: =>
    @startDate = new Pikaday
      field: @$el.find('.startDate')[0]
      format: 'M-DD-YYYY'
      minDate: moment().toDate()
    if not @model.isNew()
      @startDate.setMoment @model.getStartDate()
      $('.startDate').val(@model.getStartDate().format('M-DD-YYYY'))

  initTimePickers: =>
    @$el.find('.timepicker').timepicker
      scrollDefaultTime : "12:00"
      step : 15
    if not @model.isNew()
      @$el.find('.startTime').timepicker('setTime', @model.getStartDate().toDate());
      @$el.find('.endTime').timepicker('setTime', @model.getEndDate().toDate());
    @$el.find('.startTime').on 'changeTime', @predictEndTime


  predictEndTime: =>
    if not @$el.find('.endTime').val()
      st = @$el.find('.startTime').timepicker('getSecondsFromMidnight')
      @$el.find('.endTime').timepicker('setTime', st+(60*60))  


  chooseCustomVenue: =>
    @$el.find('.addressButton').on 'shown.bs.popover', =>
      @$el.find('.popover-content').html("<div class='addressPopover'></div>")
      if not @subview('addressPopover')
        @subview 'addressPopover', new AddressView
          container : @$el.find('.addressPopover')
          model : @model
          template: require('templates/addressPopover')
    @$el.find('.addressButton').popover({placement: 'bottom', content : "<div class='addressPopover'>Address Finder</div>", container: 'div.address-finder', html: true}).popover('show')
    @delegate 'click', '.closeAddress', ->
      @$el.find('.addressButton').popover('hide')

  updateModel: ->
    @model.set
      fixedOccurrences : @getFixedOccurrences()    

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
    console.log 'event edit postsave'
    if $('.promote-checkbox').is(':checked')
      if @isNew
        @collection.add @model
        @publishEvent '#{@noun}:created', @model
      @publishEvent '!router:route', "/event/#{@model.id}/promote"
    else
      super()

  showPromote:(show)=>
    if show
      $('.promotion-selection').show()
    else
      $('.promotion-selection').hide()
