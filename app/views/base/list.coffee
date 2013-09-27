template = require 'templates/business/list'
CollectionView = require 'views/base/collection-view'
MessageArea = require 'views/messageArea'



module.exports = class List extends CollectionView
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
      Chaplin.mediator.execute('router:changeURL', "#{baseUrl}")
      @publishEvent 'message:publish', 'error', @params.error
    else if @params?.success
      Chaplin.mediator.execute('router:changeURL', "#{baseUrl}")
      @publishEvent 'message:publish', 'success', @params.success  
    if @collection?.length is 0    
      @$el.find('.hideInitial').hide();  

  hideInitialStage: (e) =>
    @$el.find('.initial-state').hide()
    @$el.find('.hideInitial').show();

  create: =>
    @hideInitialStage()
    @publishEvent "closeOthers"
    Chaplin.helpers.redirectTo {url: @noun}

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