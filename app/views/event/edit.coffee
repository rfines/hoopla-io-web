template = require 'templates/event/edit'
View = require 'views/base/view'
Event = require 'models/event'
AddressView = require 'views/address'
ImageChooser = require 'views/common/imageChooser'
ImageUtils = require 'utils/imageUtils'

module.exports = class EventEditView extends View
  autoRender: true
  className: 'event-edit'
  template: template
  events:
    'click .event-submit' : 'save'
    
  initialize: ->
    super

  attach: =>
    super
    @modelBinder.bind @model, @$el
    @subview('imageChooser', new ImageChooser({container: @$el.find('.imageChooser')}))
    @initTimePickers()
    @initDatePickers()
    @attachAddressFinder()    
    @$el.find(".select-chosen").chosen({width:'100%'})
    $('.business').on 'change', (evt, params) =>
      @model.set 'business', params.selected
    $('.host').on 'change', (evt, params) =>
      @model.set 
      'host' : params.selected
      'location' : Chaplin.datastore.business.get(params.selected).get('location')

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

  attachAddressFinder: =>
    @$el.find('.addressButton').popover({placement: 'bottom', content : "<div class='addressPopover'>Hello</div>", container: 'div.address-finder', html: true}).popover('show').popover('hide')
    @$el.find('.addressButton').on 'shown.bs.popover', =>
      @$el.find('.popover-content').html("<div class='addressPopover'></div>")
      @removeSubview('addressPopover') if @subview('addressPopover')
      @subview('addressPopover', new AddressView({container : @$el.find('.addressPopover'), model : @model}))  

  getTemplateData: =>
    td = super()
    td.businesses = Chaplin.datastore.business.models
    td.isNew = @model.isNew()
    media = @model.get('media')
    if media?.length > 0
      td.imageUrl = $.cloudinary.url(ImageUtils.getId(media[0].url), {crop: 'fill', height: 163, width: 266})
    td    


  save: (e) ->
    e.preventDefault()
    @model.set
      fixedOccurrences : @getFixedOccurrences()    
    if $("#filelist div").length > 0
      @subview('imageChooser').uploadQueue (media) =>
        @model.set 'media',[media]
        @model.save {}, {
          success: =>
            @collection.add @model
            @publishEvent '!router:route', 'myEvents'
          error: (model, response) ->
            console.log response
        }
    else
      @model.save {}, {
          success: =>
            @collection.add @model
            @publishEvent '!router:route', 'myEvents'
          error: (model, response) ->
            console.log response
      }

  getFixedOccurrences: =>
    sd = @startDate.getMoment()
    sd.add('seconds', @$el.find("input[name='startTime']").timepicker('getSecondsFromMidnight'))
    ed = @startDate.getMoment()
    ed.add('seconds', @$el.find("input[name='endTime']").timepicker('getSecondsFromMidnight'))
    return [{
      start : sd.toDate().toISOString()
      end : ed.toDate().toISOString()
    }]