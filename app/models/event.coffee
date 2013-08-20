Model = require 'models/base/model'

module.exports = class Event extends Model
  
  url: ->
    if @isNew()
      return "/api/event"
    else
      return "/api/event/#{@id}"  