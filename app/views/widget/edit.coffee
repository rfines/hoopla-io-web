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
    console.log @model
    @modelBinder.bind @model, @$el
    @$el.find(".select-chosen").chosen({width:'100%'})    
    @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))
    @updatePreview() if not @model.isNew()


  getTemplateData: ->
    td = super()
    td.eventTags = Chaplin.datastore.eventTag.models
    td    

  updateModel: ->
    console.log 'update model'

  events:
    'click .saveButton' : 'save'
    'click .cancel':'cancel' 
    'click .previewButton' : 'preview'   

  cancel:()->
    @publishEvent '!router:route', @listRoute        

  save: () ->
    @model.set
      geo : @subview('geoLocation').getLocation().geo
    @model.save()

  preview: () ->
    @model.set
      geo : @subview('geoLocation').getLocation().geo
    @model.save {}, {
      success: (err, doc) =>
        @updatePreview()
    }

  updatePreview: () =>
    $('#widgetPreview').attr('src', "http://localhost:3000/integrate/widget/#{@model.id}")

