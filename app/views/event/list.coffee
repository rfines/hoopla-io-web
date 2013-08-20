template = require 'templates/event/list'
CollectionView = require 'views/base/collection-view'
EventListItem = require 'views/event/listItem'

module.exports = class List extends CollectionView
  autoRender: true
  renderItems: true
  className: 'event-list'
  template: template
  itemView: EventListItem

  initialize: ->
    super

  events:
    "click button" : "create"

  create: =>
    @publishEvent '!router:route', 'demo/event'    