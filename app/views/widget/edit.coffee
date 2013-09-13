template = require 'templates/widget/edit'
View = require 'views/base/inlineEdit'
AddressView = require 'views/address'
Model = require 'models/widget'

module.exports = class WidgetEditView extends View
  className: 'widget-edit'
  template: template
  listRoute: 'myWidgets'
  noun : 'widget'

  attach: ->
    super
    @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))
    $('.widgetType').on 'change', (e) =>
      widgetType = @$el.find('input[name=widgetType]:checked').val()
      if widgetType is 'event-by-location'
        @byLocation()
      else
        @byBusiness()
    if not @model.isNew()
      @updatePreview()   
      if @model.get('widgetType') is 'event-by-location'
        @byLocation() 
      else
        @byBusiness()
    $('.colorpicker').spectrum({
      showInput : true
    })


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
    'click .cancelButton':'cancel' 
    'click .previewButton' : 'preview'    

  preview: () ->
    @updateModel()
    if @validate()
      @model.save {}, {
        success: (err, doc) =>
          @updatePreview()
      }

  updatePreview: () =>
    @$el.find('.static-widget-preview').hide()
    @$el.find('#widgetPreview').attr('src', @getIframeSrc())
    @$el.find('#widgetPreview').attr('style', "height:#{@model.get('height')}px;width:#{@model.get('width')}px;border-radius:4px;")
    @$el.find('.embedCodeHtml').text("<iframe scrolling=\"no\" style=\"border-radius:4px\" src=\"#{@getIframeSrc()}\" style=\"height:#{@model.get('height')}px;width:#{@model.get('width')}px;\"></iframe>")

  getIframeSrc: () =>
    return "#{window.baseUrl}integrate/widget/#{@model.id}"

  byLocation: () =>
    @$el.find('.event-by-business').hide()
    @$el.find('.event-by-location').show()

  byBusiness: () =>
    @$el.find('.event-by-business').show()
    @$el.find('.event-by-location').hide()
