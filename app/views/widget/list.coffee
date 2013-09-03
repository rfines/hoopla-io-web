ListView = require 'views/base/list'
template = require 'templates/widget/list'
ListItem = require 'views/widget/listItem'

module.exports = class List extends ListView
  className: 'event-list'
  template: template
  itemView: ListItem
  noun : 'widget'
