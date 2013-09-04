Collection = require 'models/base/collection'
Media = require('models/media')

module.exports = class Medias extends Collection
  model : Media
  url: "/api/user/#{$.cookie('user')}/media"
  
  hasOne: ->
    @length is 1