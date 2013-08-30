Collection = require 'models/base/collection'
Widget = require('models/widget')

module.exports = class Widgets extends Collection
  model : Widget
  url: ->
    "/api/user/#{$.cookie('user')}/widgets"
  
