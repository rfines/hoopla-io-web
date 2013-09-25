template = require 'templates/messageArea'
View = require 'views/base/view'

module.exports = class MessageArea extends View
  className: 'alert'
  template: template
  containerMethod: 'html'

  listen:
    "message:publish mediator": 'updateMessage'


  initialize: ->
    super

  updateMessage: (type, text) ->
    @$el.removeClass('alert-danger').removeClass('alert-success')
    if type is 'error'
      @$el.addClass('alert-danger')
    else
      @$el.addClass('alert-success')
    @$el.empty().html(text)