template = require 'templates/blog'
View = require 'views/base/view'

module.exports = class HomePageView extends View
  autoRender: true
  className: 'home-page'
  template: template

  initialize: (@options) ->
    super(options)

  attach: ->
    super()