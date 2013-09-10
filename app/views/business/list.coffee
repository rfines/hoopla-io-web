ListView = require 'views/base/editableList'
template = require 'templates/business/list'
ListItem = require 'views/business/listItem'
EditView = require 'views/business/edit'
Model = require 'models/business'

module.exports = class List extends ListView
  className: 'business-list'
  template: template
  itemView: ListItem
  noun : 'business'
  listSelector: '.business-list-container'
  listRoute : 'myBusinesses'
  EditView : EditView
  Model : Model  