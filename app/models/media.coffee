Model = require 'models/base/model'

module.exports = class Media extends Model
  url: ->
    if @isNew()
      return "/api/user/#{$.cookie('user')}/media/upload"
    else
      return "/api/user/#{$.cookie('user')}/media/"

    