template = require 'templates/widget/edit'
View = require 'views/base/inlineEdit'
AddressView = require 'views/address'
Model = require 'models/widget'

module.exports = class WidgetEditView extends View
  className: 'widget-edit'
  template: template
  listRoute: 'myWidgets'
  noun : 'widget'
  saving = false
  listen:
    'change model' : 'preview'
  saving = false
  attach: ->
    super
    @$el.find('.embedCode').hide()
    @$el.find('#widgetPreview').hide()
    $('.widgetType').on 'change', (e) =>
      widgetType = @$el.find('input[name=widgetType]:checked').val()
      if widgetType is 'event-by-location'
        @byLocation()
      else
        @byBusiness()
    if not @model.isNew()
      @$el.find('.embedCode').show()
      @updatePreview()   
      if @model.get('widgetType') is 'event-by-location'
        @byLocation() 
      else
        @byBusiness()
    $('.colorpicker').spectrum({
      showInput : true
    })
    if not @model.has('widgetType') 
      @$el.find('.event-by-business').hide()
      @$el.find('.event-by-location').hide()
    $radioButtons = $("input[type=\"radio\"]")
    $radioButtons.click ->
        $radioButtons.each ->
          $(this).closest(".radio").toggleClass "selected", @checked


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

  validate: ->
    @$el.find('.has-error').removeClass('has-error')
    errs = @model.validate()
    if @model.get('widgetType') is 'event-by-location' and (not @model.get('location')?.geo?.coordinates?.length > 0)
      errs = errs || {}
      errs.address = 'required'
    if errs
      for x in _.keys(errs)
        @$el.find("input[name=#{x}], textarea[name=#{x}]").parent().addClass('has-error')
      return false
    else
      return true        

  preview: () =>
    @updateModel()
    if @validate() and not @saving
      @saving = true
      @model.save {}, {
        success: (err, doc) =>
          @saving = false
          @publishEvent 'stopWaiting'
          @updatePreview()
        error:(err) =>
          @publishEvent 'stopWaiting'
          @saving = false
      }

  updatePreview: () =>
    @$el.find('.static-widget-preview').hide()
    @$el.find('#widgetPreview').attr('src', @getIframeSrc())
    @$el.find('#widgetPreview').attr('style', "height:#{@model.get('height')}px;width:#{@model.get('width')}px;border-radius:4px;")
    @$el.find('.embedCodeHtml').text("<iframe scrolling=\"no\" style=\"border-radius:4px;height:#{@model.get('height')}px;width:#{@model.get('width')}px;\" src=\"#{@getIframeSrc()}\" ></iframe>")
    @$el.find('.widgetPreviewContainer').height(@model.get('height')).width(@model.get('width'))
    @$el.find('.embedCode').show()

  getIframeSrc: () =>
    return "#{window.baseUrl}integrate/widget/#{@model.id}"

  byLocation: () =>
    @$el.find('.widgetHelp').hide()
    @$el.find('.event-by-business').hide()
    @$el.find('.event-by-location').show()

  byBusiness: () =>
    @$el.find('.widgetHelp').hide()
    @$el.find('.event-by-business').show()
    @$el.find('.event-by-location').hide()