template = require 'templates/messageArea'
View = require 'views/base/view'

module.exports = class MessageArea extends View
  className: 'alert'
  template: template
  containerMethod: 'html'

  initialize: ->
    super

  attach:()->
    super()
    @subscribeEvent "message:close", @closeMessage
    @subscribeEvent "message:publish", @updateMessage

  updateMessage: (type, text) =>
    console.log @$el
    console.log type
    console.log text
    @$el.removeClass('alert-danger').removeClass('alert-success')
    if type is 'error'
      @$el.addClass('alert-danger')
    else
      @$el.addClass('alert-success')
    @$el.html(text)
    console.log @$el.html()
    @$el.parent().show()
    console.log @$el.is(":visible")

    console.log @$el.parent().is(":visible")
    
  closeMessage: ()=>
    if @$el.is(':visible')
      @$el.slideUp()