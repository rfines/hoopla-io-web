View = require 'views/base/view'
template = require 'views/templates/users/user-item'

module.exports = class HeaderView extends View
  autoRender: true
  template: template

  events: 
    "click a": "removeUser"

  removeUser: (e)->
    @model.destroy
      success: =>
        @dispose()
      error: =>
        console.log 'error'
    

