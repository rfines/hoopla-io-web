ListView = require 'views/base/editableList'
template = require 'templates/widget/list'
ListItem = require 'views/widget/listItem'
EditView = require 'views/widget/edit'
Model = require 'models/widget'

module.exports = class List extends ListView
  className: 'widget-list'
  template: template
  itemView: ListItem
  noun : 'widget'
  listSelector: '.widget-list-container'
  EditView : EditView
  Model : Model

  attach: ->
    super()
    @publishEvent 'activateNav', "myWidgets"