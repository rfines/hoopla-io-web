View = require 'views/base/view'

module.exports = class InlineEdit extends View

  initialize: ->
    super()
    @isNew = @model.isNew()

  cancel: (e) ->
    if @model.isNew()
      super()
    else
      e.stopPropagation() if e
      @publishEvent "#{@noun}:#{@model.id}:edit:close"

  postSave: =>
    if @isNew
      @collection.add @model
      @publishEvent '#{@noun}:created', @model
      @dispose()
    else
      @publishEvent "#{@noun}:#{@model.id}:edit:close"     

  attach: ->
    super
    @modelBinder.bind @model, @$el
    Backbone.Validation.bind(@)
    @$el.find(".select-chosen").chosen({width:'100%'})  
    @$el.find(".select-chosen-nosearch").chosen({width:'100%', disable_search: true})            

  getTemplateData: ->
    td = super
    td.isNew = @model.isNew()
    td.hasMedia = Chaplin.datastore.media.length > 0
    td.hasBusinesses = Chaplin.datastore.business.length > 0
    td.hasSingleBusiness = Chaplin.datastore.business.length is 1
    td.hasMultipleBusinesses = Chaplin.datastore.business.length > 1
    td