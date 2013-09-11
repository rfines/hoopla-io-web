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
    'click .cancelButton':'cancel' 
    'click .previewButton' : 'preview'    

  save: () ->
    @updateModel()
    @model.save {}, {
      success: =>
        @postSave() if @postSave
    }

  preview: () ->
    @updateModel()
    @model.save {}, {
      success: (err, doc) =>
        @updatePreview()
    }

  updatePreview: () =>
    $('#widgetPreview').attr('src', @getIframeSrc())
    $('#widgetPreview').attr('style', "height:#{@model.get('height')}px;width:#{@model.get('width')}px;border-radius:4px;")
    $('.embedCodeHtml').text("<iframe scrolling=\"no\" style=\"border-radius:4px\" src=\"#{@getIframeSrc()}\" style=\"height:#{@model.get('height')}px;width:#{@model.get('width')}px;\"></iframe>")

  getIframeSrc: () =>
    return "#{window.baseUrl}integrate/widget/#{@model.id}"

  byLocation: () =>
    @$el.find('.event-by-business').hide()
    @$el.find('.event-by-location').show()

  byBusiness: () =>
    @$el.find('.event-by-business').show()
    @$el.find('.event-by-location').hide()
