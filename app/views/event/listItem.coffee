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
    
