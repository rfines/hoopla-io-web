Collection = require 'models/base/collection'
Business = require('models/business')

module.exports = class Events extends Collection
  Model : Business
  url: ->
    "/api/user/#{$.cookie('user')}/events"
  
