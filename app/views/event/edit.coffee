template = require 'templates/event/edit'
View = require 'views/base/edit'
Event = require 'models/event'
AddressView = require 'views/address'
ImageUtils = require 'utils/imageUtils'

module.exports = class EventEditView extends View
  autoRender: true
  className: 'event-edit'
  template: template
  listRoute: 'myEvents'

  initialize: ->
    super()
    @isNew = @model.isNew()

  attach: =>
    super
    @initTimePickers()
    @initDatePickers()
    @attachAddressFinder()    
    $('.business').on 'change', (evt, params) =>
      @model.set 'business', params.selected
    $('.host').on 'change', (evt, params) =>
      @model.set 
        'host' : params.selected
        'location' : Chaplin.datastore.business.get(params.selected).get('location')
      console.log @model.attributes
    @subscribeEvent 'selectedMedia', @updateImage   
    @delegate 'click', '.showMediaLibrary', (e) =>
      e.stopPropagation()
      console.log 'click happened'
      if @model.isNew()
        $("#media-library-popover-").modal()
      else
        $("#media-library-popover-#{@model.id}").modal()


  initDatePickers: =>
    @startDate = new Pikaday
      field: @$el.find('.startDate')[0]
    if not @model.isNew()
      @startDate.setMoment @model.getStartDate()
      $('.startDate').val(@model.getStartDate().format('YYYY-MM-DD'))

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


  attachAddressFinder: =>
    @$el.find('.addressButton').popover({placement: 'bottom', content : "<div class='addressPopover'>Hello</div>", container: 'div.address-finder', html: true}).popover('show').popover('hide')
    @$el.find('.addressButton').on 'shown.bs.popover', =>
      @$el.find('.popover-content').html("<div class='addressPopover'></div>")
      @removeSubview('addressPopover') if @subview('addressPopover')
      @subview('addressPopover', new AddressView({container : @$el.find('.addressPopover'), model : @model}))  

  getTemplateData: =>
    td = super()
    td.businesses = Chaplin.datastore.business.models
    td    

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

  cancel: (e) ->
    if @model.isNew()
      super()
    else
      e.stopPropagation() if e
      @publishEvent "event:#{@model.id}:edit:close"

  postSave: =>
    if @isNew
      super()
    else
      @publishEvent "event:#{@model.id}:edit:close"