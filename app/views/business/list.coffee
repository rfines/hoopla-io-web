template = require 'templates/business/list'
CollectionView = require 'views/base/collection-view'
BusinessListItem = require 'views/business/listItem'

module.exports = class List extends CollectionView
  autoRender: true
  renderItems: true
  className: 'business-list'
  template: template
  itemView: BusinessListItem

  initialize: ->
    super

  events:
    "click button" : "create"

  create: =>
    @publishEvent '!router:route', 'business'