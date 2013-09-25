template = require 'templates/business/list'
CollectionView = require 'views/base/collection-view'
MessageArea = require 'views/messageArea'



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
    @subscribeEvent "#{@noun}:created", @showCreatedMessage if @showCreatedMessage
    @subscribeEvent("#{@noun}:duplicate", @duplicate) if @duplicate

  attach: ->
    super()
    @subview('messageArea', new MessageArea({container: '.alert-container'}))
    baseUrl = window.location.href.split('?')[0].replace "#{window.baseUrl}", ""
    if @params?.error
      @publishEvent '!router:changeURL',  "#{baseUrl}"
      @publishEvent 'message:publish', 'error', @params.error
    else if @params?.success
      @publishEvent '!router:changeURL',  "#{baseUrl}"
      @publishEvent 'message:publish', 'success', @params.success      

  hideInitialStage: (e) =>
    @$el.find('.initial-state').hide()

  create: =>
    @hideInitialStage()
    @publishEvent "closeOthers"
    @publishEvent '!router:route', @noun

  initItemView: (model) =>
    return new @itemView({model : model, collection: @collection})

  showCreatedMessage: (data) =>
    if _.isObject data
      @publishEvent 'message:publish', 'success', "Your #{@noun} has been created. <a href='##{data.id}'>View</a>"
    else if _.isString(data)
      @publishEvent 'message:publish', 'success', "#{data}"
  getTemplateData: =>
    td=super()
    td.isEmpty = @collection.length is 0 if @collection
    td