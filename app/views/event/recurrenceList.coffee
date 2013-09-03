View = require 'views/base/view'

module.exports = class ListItem extends View
  template: require 'templates/event/recurrenceList'
  autoRender: true

  initialize: ->
    super
    console.log 'hi'