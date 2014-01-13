View = require 'views/base/view'

module.exports = class ListItem extends View
  autoRender: false
  className: 'row'
  noun : "business"

  attach: ->
    super
    @$el.attr('id', @model.id) if not @model.isNew()

  events:
    "click .edit" : "edit"
    "click .deleteButton" : "destroy"

  edit: (e) =>
    e.preventDefault()
    Chaplin.helpers.redirectTo {url: "#{@noun}/#{@model.id}"}

  destroy: (e) =>
    destroyConfirm = confirm("Delete this #{@noun}?")
    console.log @event
    if destroyConfirm
      m = @model
      if @event and @noun is 'promotionRequest'
        m.eventId = @event.id
      console.log m
      @collection.remove(@model)
      m.destroy()
      @dispose()   