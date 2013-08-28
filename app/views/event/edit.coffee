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
    @modelBinder.bind @model, @$el
    @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))
    @$el.find(".select-chosen").chosen()
    $('.business').on 'change', (evt, params) =>
      @model.set 'business', params.selected
    $('.host').on 'change', (evt, params) =>
      @model.set 'host', params.selected      
    @startDate = new Pikaday({ field: @$el.find('.datePicker')[0] })  
    if @model.get('location')?.address
      @$el.find('.address').val(@model.get('location').address)
      @subview("geoLocation").showGeo(@model.get('location').geo)
    @attachAddressFinder()

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
      location : @subview('geoLocation').getLocation()
      fixedOccurrences : @getFixedOccurrences()
    console.log @model
    @model.save {}, {
      success: =>
        @publishEvent '!router:route', 'myEvents'
    }

  getFixedOccurrences: ->
    sd = @startDate.getMoment()
    sd.add('hours', @model.get('startTime').split(':')[0])
    sd.add('minutes', @model.get('startTime').split(':')[1])

    ed = @startDate.getMoment()
    ed.add('hours', @model.get('endTime').split(':')[0])
    ed.add('minutes', @model.get('endTime').split(':')[1])    

    return [{
      start : sd.toDate().toISOString()
      end : ed.toDate().toISOString()
    }]