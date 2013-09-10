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
    "click .createButton" : "create"

  initialize: (options) ->
    super(options)
    @params = options.params
    @publishEvent 'activateNav', @listRoute

  attach: ->
    super()
    if @params?.error
      @$el.find('.listAlert').removeClass('hide')
      @$el.find('.listAlert').text @params.error

  create: =>
    console.log 'create'
    @publishEvent '!router:route', @noun

  initItemView: (model) =>
    return new @itemView({model : model, collection: @collection})