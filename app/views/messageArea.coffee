template = require 'templates/messageArea'
View = require 'views/base/view'

module.exports = class MessageArea extends View
  className: 'alert'
  template: template
  containerMethod: 'html'

  listen:
    "message:publish mediator": 'updateMessage'
    "message:close mediator":"closeMessage"

  initialize: ->
    super

  attach:()->
    super()
    @subscribeEvent "message:close", @closeMessage
    @subscribeEvent "message:publish", @updateMessage

  updateMessage: (type, text) ->
    @$el.removeClass('alert-danger').removeClass('alert-success')
    if type is 'error'
      @$el.addClass('alert-danger')
    else
      @$el.addClass('alert-success')
    if @$el.is(':visible')
      @$el.empty().html(text)
    else
      @$el.empty().html(text).slideDown()
      
  closeMessage: ()=>
    if @$el.is(':visible')
      @$el.slideUp()