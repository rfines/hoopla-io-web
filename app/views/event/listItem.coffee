View = require 'views/base/view'
template = require 'templates/event/listItem'

module.exports = class ListItem extends View
  autoRender: true
  template: template
  className: 'row'

  events:
    "click .edit" : "edit"
    "click .deleteButton" : "destroy"

  edit: (e) =>
    e.preventDefault()
    @publishEvent '!router:route', "/event/#{@model.id}"  

  destroy: (e) =>
    @model.destroy()
    Chaplin.datastore.event.remove(@model)
    @dispose()
    
  getTemplateData: =>
    td = super()
    td.dateText = @model.nextOccurrenceText()
    td.businessName = Chaplin.datastore.business.get(@model.get('business')).get('name')
    td