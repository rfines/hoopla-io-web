template = require 'templates/widget/edit'
View = require 'views/base/view'
AddressView = require 'views/address'
Widget = require 'models/widget'

module.exports = class WidgetEditView extends View
  className: 'widget-edit'
  template: template
  listRoute: 'myWidgets'

  initialize: ->
    super
    @model = @model || new Widget()

  attach: ->
    super
    @modelBinder.bind @model, @$el
    @$el.find(".select-chosen").chosen({width:'100%'})    
    @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))
    $('.widgetType').on 'change', (evt, params) =>
      if params.selected is 'event-by-location'
        @byLocation()
      else
        @byBusiness()
    if not @model.isNew()
      @updatePreview()   
      if @model.get('widgetType') is 'event-by-location'
        @byLocation() 
      else
        @byBusiness()


  getTemplateData: ->
    td = super()
    td.eventTags = Chaplin.datastore.eventTag.models
    td.businesses = Chaplin.datastore.business.models
    td    

  updateModel: ->
    @model.set
      location : @subview('geoLocation').getLocation()

  events:
    'click .saveButton' : 'save'
    'click .cancel':'cancel' 
    'click .previewButton' : 'preview'   

  cancel:()->
    @publishEvent '!router:route', @listRoute        

  save: () ->
    @updateModel()
    @model.save()

  preview: () ->
    @updateModel()
    @model.save {}, {
      success: (err, doc) =>
        @updatePreview()
    }

  updatePreview: () =>
    $('#widgetPreview').attr('src', "http://localhost:3000/integrate/widget/#{@model.id}")


  byLocation: () =>
    @$el.find('.event-by-business').hide()
    @$el.find('.event-by-location').show()

  byBusiness: () =>
    @$el.find('.event-by-business').show()
    @$el.find('.event-by-location').hide()
