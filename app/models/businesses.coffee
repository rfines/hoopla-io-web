Collection = require 'models/base/collection'
Business = require('models/business')

module.exports = class Businesses extends Collection
  model : Business
  url: ->
    "/api/user/#{$.cookie('user')}/businesses"

  hasOne: ->
    @length is 1

  hasNone: ->
    @length is 0