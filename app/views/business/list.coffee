ListView = require 'views/base/list'
template = require 'templates/business/list'
ListItem = require 'views/business/listItem'

module.exports = class List extends ListView
  className: 'business-list'
  template: template
  itemView: ListItem
  noun : 'business'