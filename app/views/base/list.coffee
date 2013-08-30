template = require 'templates/business/list'
CollectionView = require 'views/base/collection-view'

module.exports = class List extends CollectionView
  autoRender: true
  renderItems: true
  itemView: Chaplin.View
  noun : undefined
  className: undefined
  template: undefined

  events:
    "click button" : "create"

  create: =>
    @publishEvent '!router:route', @noun

  initItemView: (model) =>
    return new @itemView({model : model, collection: @collection})