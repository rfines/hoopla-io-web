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
    @publishEvent '!router:route', "/event/#{@model.id}"  