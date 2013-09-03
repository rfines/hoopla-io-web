ListView = require 'views/base/list'
template = require 'templates/event/list'
ListItem = require 'views/event/listItem'

module.exports = class List extends ListView
  className: 'event-list'
  template: template
  itemView: ListItem
  noun : 'event'
  listSelector : '#accordion'
  
  initialize: (options) ->
    super(options)