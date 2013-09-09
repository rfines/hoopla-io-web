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


  getTemplateData: ->
    td = super()
    td.eventTags = Chaplin.datastore.eventTag.models
    td    

  updateModel: ->
    console.log 'update model'

  events:
    'click .saveButton' : 'save'
    'click .cancel':'cancel'    

  cancel:()->
    @publishEvent '!router:route', @listRoute        

  save: () ->
    @model.set
      geo : @subview('geoLocation').getLocation().geo
    console.log @model
    @model.save()