template = require 'templates/messageArea'
View = require 'views/base/view'

module.exports = class MessageArea extends View
  autoRender: true
  className: 'alert'
  template: template

  listen:
    "message:publish mediator": 'updateMessage'


  initialize: ->
    super

  updateMessage: (type, text) ->
    if type is 'error'
      @$el.addClass('alert-danger')
    else
      @$el.addClass('alert-success')
    @$el.empty().html(text)