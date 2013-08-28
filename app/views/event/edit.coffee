template = require 'templates/event/edit'
View = require 'views/base/view'
Event = require 'models/event'
AddressView = require 'views/address'

module.exports = class EventEditView extends View
  autoRender: true
  className: 'event-edit'
  template: template

  initialize: ->
    super

  attach: =>
    super
    @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))
    @$el.find(".select-chosen").chosen()
    @$el.find('.timepicker').timepicker
      scrollDefaultTime : "12:00"
    $('.business').on 'change', (evt, params) =>
      @model.set 'business', params.selected
    $('.host').on 'change', (evt, params) =>
      @model.set 
      'host' : params.selected
      'location' : Chaplin.datastore.business.get(params.selected).get('location')

    @startDate = new Pikaday({ field: @$el.find('.datePicker')[0] })  
    console.log @startDate
    @attachAddressFinder()
    @modelBinder.bind @model, @$el

  attachAddressFinder: =>
    @$el.find('.addressButton').popover({placement: 'bottom', content : "<div class='addressPopover'>Hello</div>", html: true}).popover('show').popover('hide')
    @$el.find('.addressButton').on 'shown.bs.popover', =>
      @$el.find('.popover-content').html("<div class='addressPopover'></div>")
      @removeSubview('addressPopover') if @subview('addressPopover')
      @subview('addressPopover', new AddressView({container : @$el.find('.addressPopover')}))  


  events:
    'submit form' : 'save'

  getTemplateData: ->
    td = super()
    td.businesses = Chaplin.datastore.business.models
    td    

  save: (e) ->
    e.preventDefault()
    @model.set
      fixedOccurrences : @getFixedOccurrences()
    console.log @model
    @model.save {}, {
      success: =>
        Chaplin.datastore.event.add @model
        @publishEvent '!router:route', 'myEvents'
    }

  getFixedOccurrences: =>
    sd = @startDate.getMoment()
    console.log @startDate
    console.log sd
    sd.add('seconds', @$el.find("input[name='startTime']").timepicker('getSecondsFromMidnight'))
    ed = @startDate.getMoment()
    ed.add('seconds', @$el.find("input[name='endTime']").timepicker('getSecondsFromMidnight'))
    return [{
      start : sd.toDate().toISOString()
      end : ed.toDate().toISOString()
    }]