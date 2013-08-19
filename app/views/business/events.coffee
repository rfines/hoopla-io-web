View = require 'views/base/view'
template = require 'templates/business/events'
Business = require 'models/business'
BusinessListItem = require 'views/business/listItem'

module.exports = class Events extends CollectionView
  autoRender: true
  renderItems: true
  className: 'business-events-list'
  template: template
  itemView: BusinessListItem

  initialize: ->
    super

  events:
    "click button" : "create"

  businessEvents : ->
    console.log "Getting events"

  create:->
    console.log "Create events"