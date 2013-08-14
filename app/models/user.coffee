Model = require 'models/base/model'

module.exports = class User extends Model
  
  url: ->
    if @isNew()
      return "/api/user"
    else
      return "/api/user/#{@id}"