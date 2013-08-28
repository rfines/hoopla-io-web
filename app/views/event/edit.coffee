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
    'submit form' : 'save'
    
  initialize: ->
    super

  attach: =>
    super
    @subview('imageChooser', new ImageChooser({container: @$el.find('.imageChooser')}))
    @initTimePickers()
    @initDatePickers()
    @attachAddressFinder()    
    @$el.find(".select-chosen").chosen()
    $('.business').on 'change', (evt, params) =>
      @model.set 'business', params.selected
    $('.host').on 'change', (evt, params) =>
      @model.set 
      'host' : params.selected
      'location' : Chaplin.datastore.business.get(params.selected).get('location')
    @modelBinder.bind @model, @$el

  initDatePickers: =>
    @startDate = new Pikaday({ field: @$el.find('.datePicker')[0] })  

  initTimePickers: =>
    @$el.find('.timepicker').timepicker
      scrollDefaultTime : "12:00"
      step : 15

  attachAddressFinder: =>
    @$el.find('.addressButton').popover({placement: 'bottom', content : "<div class='addressPopover'>Hello</div>", html: true}).popover('show').popover('hide')
    @$el.find('.addressButton').on 'shown.bs.popover', =>
      @$el.find('.popover-content').html("<div class='addressPopover'></div>")
      @removeSubview('addressPopover') if @subview('addressPopover')
      @subview('addressPopover', new AddressView({container : @$el.find('.addressPopover')}))  

  getTemplateData: ->
    td = super()
    td.businesses = Chaplin.datastore.business.models
    media = @model.get('media')
    if media?.length > 0
      #td.imageUrl = media[0].url
      td.imageUrl = $.cloudinary.url(ImageUtils.getId(media[0].url), {crop: 'fill', height: 163, width: 266})
      console.log media[0].url
      console.log td.imageUrl
    td    


  save: (e) ->
    e.preventDefault()
    if @model.get('media') and @subview('imageChooser').getMedia()
      @model.get('media').push @subview('imageChooser').getMedia()
    else if @subview('imageChooser').getMedia()
      @model.set 'media',[@subview('imageChooser').getMedia()]    
    @model.set
      fixedOccurrences : @getFixedOccurrences()
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