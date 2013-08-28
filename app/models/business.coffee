Model = require 'models/base/model'

module.exports = class Business extends Model
  url: ->
    if @isNew()
      return "/api/business"
    else
      return "/api/business/#{@id}"  
