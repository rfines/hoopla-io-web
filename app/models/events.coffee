Collection = require 'models/base/collection'
Event = require('models/event')

module.exports = class Events extends Collection
  model : Events
  url: ->
    "/api/user/#{$.cookie('user')}/events"
  
