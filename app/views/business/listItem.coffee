View = require 'views/base/view'
template = require 'templates/business/listItem'

module.exports = class ListItem extends View
  autoRender: true
  template: template
  className: 'row'

  events:
    "click .edit" : "edit"

  edit: (e) =>
    e.preventDefault()
    console.log "demo/business/#{@model.id}"
    console.log @publishEvent
    console.log @redirectToRoute
    @publishEvent '!router:route', "/demo/business/#{@model.id}"