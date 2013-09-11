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
    @$el.find(".select-chosen").chosen({width:'100%'})  
    @$el.find(".select-chosen-nosearch").chosen({width:'100%', disable_search: true})            
