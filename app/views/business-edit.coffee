template = require 'templates/business/edit'
View = require 'views/base/view'

module.exports = class BusinessEditView extends View
  autoRender: true
  className: 'users-list'
  template: template

  initialize: ->
    super